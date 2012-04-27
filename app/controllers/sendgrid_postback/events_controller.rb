# http://docs.sendgrid.com/documentation/api/event-api/

class SendgridPostback::EventsController < ActionController::Metal
  #before_filter :authenticate
  
  # To test, both single and multiple JSON elements in request:
  # curl -i -H "Content-Type: application/json" -X POST -d '{"email": "test2@gmail.com", "event": "processed2"}' https://localhost:3000/sendgrid_postback/events
  # curl -i -H "Content-Type: application/json" -X POST -d '{"email": "test@gmail.com", "event": "processed"}{"email": "test2@gmail.com", "event": "processed2"}' https://localhost:3000/sendgrid_postback/events
  def create
    unless request.ssl?
      self.response_body = ''
      self.status = :bad_request
      return
    end

    parse_send_grid_events do |data|
      receiver = SendgridPostback.config.find_receiver_by_uuid.call(data[:uuid])
      if receiver.blank?
        SendgridPostback.config.report_exception.call("SendgridPostback postback: Notification UUID(#{data[:uuid]}) not found.")
      else
        receiver.post_sendgrid_event(data)
      end
    end
    self.response_body = ''
  rescue => exc
    SendgridPostback.config.report_exception.call(exc)
    self.response_body = ''
    self.status = :internal_server_error
  end

  private

  # As of 2011-12-15, SendGrid reports that HTTP auth is not actually supported, despite docs
  def authenticate
    # authenticate_or_request_with_http_basic do |username, password|
    # end
  end

  def parse_send_grid_events &block
    params[:events].sort{|x, y| x[:timestamp].to_i <=> y[:timestamp].to_i}.each do |event|
      yield(event)
    end if params[:events].present?
  end

end
