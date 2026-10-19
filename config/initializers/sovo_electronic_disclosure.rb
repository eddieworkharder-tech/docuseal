# frozen_string_literal: true

# SOVO DocuSeal electronic-record disclosure gate.
# The cutoff is supplied by deploy/.env at deployment time so previously sent
# submissions retain their original signing flow.
module SovoElectronicDisclosureGate
  VERSION = 'SOVO-ERSD-2026-10-15-v1'.freeze
  PREFERENCE_KEY = 'sovo_electronic_disclosure'.freeze

  def show
    return super unless sovo_ersd_required? && !sovo_ersd_accepted?
    return super if performed?
    return super unless Submitters::AuthorizedForForm.pass_email_2fa?(@submitter, request)
    return super if @submitter.completed_at? || @submitter.submission.completed_at?

    @sovo_ersd_version = SovoElectronicDisclosureGate::VERSION
    render 'submit_form/sovo_electronic_disclosure', layout: 'form'
  end

  def update
    return super unless sovo_ersd_required?

    unless sovo_ersd_accepted?
      return render(json: { error: 'Please accept the electronic records and signature disclosure first.' },
                    status: :unprocessable_content) unless params[:sovo_ersd_accept] == '1'

      return render(json: { error: 'This signing link is not authorized.' },
                    status: :forbidden) unless Submitters::AuthorizedForForm.call(@submitter, current_user, request)
      return render(json: { error: 'This form cannot be signed.' },
                    status: :unprocessable_content) if @submitter.viewer? || @submitter.completed_at? ||
                                                       @submitter.submission.completed_at? ||
                                                       @submitter.declined_at? ||
                                                       @submitter.submission.expired? ||
                                                       @submitter.submission.archived_at? ||
                                                       @submitter.submission.template&.archived_at?

      disclosure_path = Rails.root.join('app/views/submit_form/sovo_electronic_disclosure.html.erb')
      disclosure_hash = Digest::SHA256.file(disclosure_path).hexdigest

      @submitter.with_lock do
        @submitter.reload
        unless sovo_ersd_accepted?
          accepted_at = Time.current.utc.iso8601(6)
          @submitter.update!(preferences: (@submitter.preferences || {}).deep_dup.merge(
            SovoElectronicDisclosureGate::PREFERENCE_KEY => {
              'version' => SovoElectronicDisclosureGate::VERSION,
              'accepted_at' => accepted_at,
              'sha256' => disclosure_hash
            }
          ))

          SubmissionEvents.create_with_tracking_data(
            @submitter,
            'start_form',
            request,
            {
              sovo_ersd_accepted: true,
              sovo_ersd_version: SovoElectronicDisclosureGate::VERSION,
              sovo_ersd_sha256: disclosure_hash,
              sovo_ersd_accepted_at: accepted_at
            }
          )
        end
      end

      respond_to do |format|
        format.html { redirect_to submit_form_path(@submitter.slug) }
        format.json { head :ok }
        format.all  { head :ok }
      end
      return
    end

    super
  end

  private

  def sovo_ersd_required?
    return false unless @submitter&.submission

    cutoff = Time.zone.parse(ENV.fetch('SOVO_DISCLOSURE_ENABLED_SINCE', ''))
    cutoff.present? && @submitter.submission.created_at >= cutoff
  rescue ArgumentError, TypeError
    false
  end

  def sovo_ersd_accepted?
    @submitter&.preferences&.dig(SovoElectronicDisclosureGate::PREFERENCE_KEY, 'version') ==
      SovoElectronicDisclosureGate::VERSION
  end
end

Rails.application.config.to_prepare do
  SubmitFormController.prepend(SovoElectronicDisclosureGate) unless
    SubmitFormController.ancestors.include?(SovoElectronicDisclosureGate)
end
