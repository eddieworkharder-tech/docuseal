# frozen_string_literal: true

# Attach the official SOVO logo inline so every Action Mailer email can render
# it without relying on an externally loaded image.
Rails.application.config.after_initialize do
  ApplicationMailer.default from: 'SOVO 智居签约中心 <contracts@sovosg.app>'

  unless ApplicationMailer.respond_to?(:sovo_inline_logo_hook_installed?)
    ApplicationMailer.before_action do
      logo_path = Rails.root.join('public', 'sovo-logo.png')

      if File.file?(logo_path) && attachments['sovo-logo.png'].nil?
        attachments.inline['sovo-logo.png'] = File.binread(logo_path)
      end

      attachments['sovo-logo.png'].url if attachments['sovo-logo.png']
    end

    ApplicationMailer.define_singleton_method(:sovo_inline_logo_hook_installed?) { true }
  end

  # Interceptor to temporarily hold and suspend all outgoing emails to William Xiao
  # until Eddie Tang explicitly instructs a batch dispatch.
  class WilliamEmailHoldInterceptor
    def self.delivering_email(message)
      recipients = Array(message.to) + Array(message.cc) + Array(message.bcc)
      if recipients.any? { |r| r.to_s.downcase.include?('william@sagepaths.com') }
        unless ENV['ALLOW_SEND_TO_WILLIAM'] == 'true'
          Rails.logger.warn("[SOVO HOLD] Temporarily holding email delivery to William Xiao: #{message.subject}")
          message.perform_deliveries = false
        end
      end
    end
  end

  unless defined?($william_email_interceptor_registered) && $william_email_interceptor_registered
    ActionMailer::Base.register_interceptor(WilliamEmailHoldInterceptor)
    $william_email_interceptor_registered = true
  end
end
