require_relative 'environment'

class RFlow
  module Components
    class Rails3App < Component
      input_port :request_port
      output_port :response_port

      attr_accessor :response_counter

      def configure!(config)
        @response_counter = 0
      end

      def process_message(input_port, input_port_key, connection, message)
        return unless message.data_type_name == 'RFlow::Message::Data::HTTP::Request'

        RFlow.logger.debug "Received HTTP request"

        Request.new(:data => message.data.content).tap do |r|
          RFlow.logger.debug "Response logged '#{r.data}'"
          r.save!
        end

        response = Response.new(:data => "PID #{$$} Response #{response_counter}").tap do |r|
          RFlow.logger.debug "Responding with '#{r.data}'"
          r.save!
        end

        response_port.send_message(RFlow::Message.new('RFlow::Message::Data::HTTP::Response').tap do |m|
          m.provenance = message.provenance
          m.data.content = response.data
        end)

        @response_counter += 1
      end
    end
  end
end
