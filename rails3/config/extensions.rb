require_relative 'environment'

class RFlow::Components::Rails3App < RFlow::Component
  input_port :request_port
  output_port :response_port

  def process_message(input_port, input_port_key, connection, message)
    return unless message.data_type_name == 'RFlow::Message::Data::HTTP::Request'

    response = RFlow::Message.new('RFlow::Message::Data::HTTP::Response')
    response.provenance = message.provenance
    response.data.content = "Response to #{message.data.uri} from component #{uuid}\n"

    response_port.send_message response
  end
end
