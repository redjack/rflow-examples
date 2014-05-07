require_relative 'environment'

class RFlow::Components::Rails3App < RFlow::Component
  input_port :request_port
  output_port :response_port

  attr_accessor :response_counter

  def configure!(config)
    @response_counter = 0
  end

  def process_message(input_port, input_port_key, connection, message)
    return unless message.data_type_name == 'RFlow::Message::Data::HTTP::Request'

    RFlow.logger.debug "Received HTTP request"

    request = Request.new(:data => message.data.content)
    request.save!

    RFlow.logger.debug "Response logged '#{request.data}'"

    response = Response.new(:data => "PID #{$$} Response #{response_counter}")
    response.save!

    RFlow.logger.debug "Responding with '#{response.data}'"

    response_message = RFlow::Message.new('RFlow::Message::Data::HTTP::Response')
    response_message.provenance = message.provenance
    response_message.data.content = response.data

    response_port.send_message response_message

    @response_counter += 1
  end
end
