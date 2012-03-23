require 'mail'
require 'mail/message'

module SendgridPostback

  class MailInterceptor

    # Intercept emails before they are sent, primarily to create a UUID that will be added to the mail headers.
    # SendgridPostback will post back events for messages as they are processed.
    # This is done here, rather than in a ActionMailer::Base subclass, to ensure that *all* emails get a UUID
    def self.delivering_email(email)
      set_sendgrid_headers(email)
    end

    cattr_reader :installed
    def self.install
      return if @@installed
      @@installed = true
      
      # Add a :uuid accessor to Message instances in the event we need to check it in a MailObserver later
      Mail::Message.class_eval do
        attr_accessor :uuid
      end
      register
    end

    def self.register
      ActionMailer::Base.register_interceptor(self)
    end

  private

    def self.set_sendgrid_headers email
      email.uuid = self.generate_uuid
      email.headers({:'X-SMTPAPI' => self.sendgrid_header(email.uuid)})
    end

    def self.sendgrid_header uuid
      {unique_args: {uuid: uuid}}.to_json
    end

    def self.generate_uuid
      UUIDTools::UUID.timestamp_create.to_s
    end

  end

end
