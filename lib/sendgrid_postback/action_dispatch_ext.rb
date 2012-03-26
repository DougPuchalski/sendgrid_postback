require 'yajl' unless defined?(Yajl)
require 'action_dispatch'
require 'action_dispatch/middleware/params_parser'

# An unfortunate hack: SendgridPostback events in batch mode come in as invalid JSON--not an array, but newline-separated
# hashes. Trap the middleware and parse it here.
module ActionDispatch
  ParamsParser.class_eval do
    def parse_formatted_parameters_with_sendgrid_postback(env)
      if env['PATH_INFO'] == SendgridPostback.config.postback_path
        begin
          request = Request.new(env)
          parser = ::Yajl::Parser.new
          data = {events: []}
          parser.on_parse_complete = lambda {|rec|
            data[:events] << rec.with_indifferent_access
          }
          parser.parse(request.body)
          request.body.rewind if request.body.respond_to?(:rewind)
          data
        rescue Exception => e
          # Delegate if anything goes wrong
          parse_formatted_parameters_without_send_grid(env)
        end
      else
        parse_formatted_parameters_without_send_grid(env)
      end
    end
    alias_method_chain :parse_formatted_parameters, :sendgrid_postback
  end
end
