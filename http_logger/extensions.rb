class RFlow::Components::HTTPResponder < RFlow::Component
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


class RFlow::Components::HTTPToRaw < RFlow::Component
  input_port :http_port
  output_port :raw_port

  def process_message(input_port, input_port_key, connection, message)
    raw = RFlow::Message.new('RFlow::Message::Data::Raw')

    case message.data_type_name
    when 'RFlow::Message::Data::HTTP::Request'
      raw.data.data_object['raw'] = "#{message.data_type_name} message from #{message.data.client_ip} for #{message.data.uri}\n"
    when 'RFlow::Message::Data::HTTP::Response'
      raw.data.data_object['raw'] = "#{message.data_type_name} message status #{message.data.status_code}\n"
    else
      return
    end

    raw_port.send_message raw
  end
end
