class RFlow::Components::HTTPResponder < RFlow::Component
  input_port :request_port
  output_port :response_port

  def process_message(input_port, input_port_key, connection, message)
    return unless message.data_type_name == 'RFlow::Message::Data::HTTP::Request'
    response = RFlow::Message.new('RFlow::Message::Data::HTTP::Response')
    response.provenance = message.provenance
    response.data.content = "Response to #{message.data.uri}"

    response_port.send_message response
  end
end


class RFlow::Components::HTTPToRaw < RFlow::Component
  input_port :http_port
  output_port :raw_port

  def process_message(input_port, input_port_key, connection, message)
    return unless message.data_type_name == 'RFlow::Message::Data::HTTP::Request' || message.data_type_name == 'RFlow::Message::Data::HTTP::Response'

    raw = RFlow::Message.new('RFlow::Message::Data::Raw')
    raw.data.data_object['raw'] = "#{message.data_type_name}"
    raw_port.send_message raw
  end
end
