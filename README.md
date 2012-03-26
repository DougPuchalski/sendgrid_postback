# SendgridPostback

SendgridPostback is a Rails Engine which integrates with the [SendGrid](http://sendgrid.com)
[Event API](http://docs.sendgrid.com/documentation/api/event-api/).

It includes a MailInterceptor which will attach a UUID header in all mails before they are sent.
When properly configured, SendGrid will then post events for each message to your app. You'll
know when emails are delivered, bounced, delayed, clicked, etc., according to your SendGrid 
account configuration.

Note that for performance reasons, you'll probably want to configure your Event API to batch events.
The bad news is that SendGrid POSTs newline-separate JSON objects, rather than a JSON array. As such,
ActionDispatch is patched (see action_dispatch_ext.rb) to handle the "invalid" incoming JSON.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sendgrid_postback', git: "git://github.com/aceofspades/sendgrid_postback.git"
```

You'll need to configure your SendGrid account to enable the Event API.

Configure the library, i.e. in your app's `config/initializers/sendgrid_postback.rb`:

```ruby
require 'sendgrid_postback'
SendgridPostback.configure do |config|
  config.logger = Rails::Logger

  # Path that routes to SendgridPostback::EventsController#create
  config.postback_path = '/sendgrid_postback/events'

  # proc that accepts an exception for reporting
  config.report_exception = proc { |exc| ... } # Optional

  # Required proc that returns an instance for the given uuid.
  # The class should mix in SendgridPostback::EventReceiver
  config.find_receiver_by_uuid = proc do |uuid|
    Notification.find_by_uuid(uuid) # for example
  end
end
```

## Usage

Your app should have a class, i.e. an ActiveRecord model, that mixes in SendgridPostback::EventReceiver. 
This module adds attributes that should be persisted, `sendgrid_events` and `sendgrid_state`.

```ruby
class AddEventsAndState < ActiveRecord::Migration
  def self.up
    add_column :notifications, :uuid, :string
    add_column :notifications, :state, :string
    add_column :notifications, :events, :text
  end

  def self.down
    remove_column :notifications, :uuid
    remove_column :notifications, :state
    remove_column :notifications, :events
  end
end
```

```ruby
class Notification < ActiveRecord::Base
  include SendgridPostback::EventReceiver
  serialize :sendgrid_events
end
```

Add a new or adapt your existing MailObserver to trap email after they are sent to create a receiver instance.
You may wish to also persist the email content itself.

```ruby
class MailObserver

  # Capture UUID set by MailInterceptor and create a new Notification record
  def self.delivered_email(email)
    Notification.create!({
        uuid: email.uuid
        to: email.to.to_a.join(', '),
        subject: email.subject,
        email: email.to_s
    })
  end

  def self.register
    ActionMailer::Base.register_observer(self)
  end

end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
