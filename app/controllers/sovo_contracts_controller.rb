# frozen_string_literal: true

class SovoContractsController < ApplicationController
  load_and_authorize_resource :submission, parent: false

  def index
    @status = params[:status].to_s
    @query = params[:q].to_s.strip

    @visible_submissions = @submissions.left_joins(:template)
                                        .where(submissions: { archived_at: nil })
                                        .where(templates: { archived_at: nil })

    @status_counts = {
      pending: @visible_submissions.pending.count,
      completed: @visible_submissions.completed.count,
      declined: @visible_submissions.declined.count,
      expired: @visible_submissions.expired.count,
      archived: @submissions.where.not(archived_at: nil).count
    }

    filtered = Submissions.search(current_user, @visible_submissions, @query, search_template: true)
    filtered = Submissions::Filter.call(filtered, current_user, params.permit(*Submissions::Filter::ALLOWED_PARAMS))
    @total_count = filtered.count
    @submissions = filtered.order(id: :desc).limit(50).preload(:template, :submitters)
  end
end
