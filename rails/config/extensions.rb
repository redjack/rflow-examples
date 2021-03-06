require_relative 'environment'

class RFlow
  module Components
    # Removes an HTTP request envelope and sends along the content as a raw message.
    class RemoveEnvelope < Component
      input_port :request_port
      output_port :content_port

      def process_message(input_port, input_port_key, connection, message)
        return unless message.data_type_name == 'RFlow::Message::Data::HTTP::Request'
        RFlow.logger.debug "Received HTTP request"

        content_port.send_message(
          RFlow::Message.new('RFlow::Message::Data::Raw').tap do |m|
            m.provenance = message.provenance
            m.data.raw = message.data.content || ''
          end)
      end
    end

    # Receives a raw message and sends along the content as an HTTP response.
    class AddEnvelope < Component
      input_port :content_port
      output_port :response_port

      def process_message(input_port, input_port_key, connection, message)
        return unless message.data_type_name == 'RFlow::Message::Data::Raw'

        response_port.send_message(RFlow::Message.new('RFlow::Message::Data::HTTP::Response').tap do |m|
          m.provenance = message.provenance
          m.data.content = message.data.raw || ''
        end)
      end
    end

    # Receives a raw piece of data and acts just as Rails3App does, but responds with raw.
    class RawApp < Component
      input_port :request_port
      output_port :response_port

      attr_accessor :response_counter

      def configure!(config)
        @response_counter = 0
      end

      def process_message(input_port, input_port_key, connection, message)
        return unless message.data_type_name == 'RFlow::Message::Data::Raw'

        Request.new(:data => message.data.raw).tap do |r|
          RFlow.logger.debug "Response logged '#{r.data}'"
          r.save!
        end

        response = Response.new(:data => "PID #{$$} Response #{response_counter}").tap do |r|
          RFlow.logger.debug "Responding with '#{r.data}'"
          r.save!
        end

        response_port.send_message(RFlow::Message.new('RFlow::Message::Data::Raw').tap do |m|
          m.provenance = message.provenance
          m.data.raw = response.data || ''
        end)

        @response_counter += 1
      end
    end

    # A Rails-style app that accepts HTTP requests directly and responds with HTTP responses.
    class Rails3App < Component
      input_port :request_port
      output_port :response_port

      attr_accessor :response_counter

      def configure!(config)
        @response_counter = 0
      end

      def process_message(input_port, input_port_key, connection, message)
        begin
          Log4r::MDC.put('provenance', "[#{message.provenance.first.context}] ") if message.provenance.first
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

          if false
            # Once the debug point has been hit once, the process will be paused at the breakpoint.
            # You have to make sure you use a different port per process, which is also why we can't
            # open the debugger prior to the fork and run. You can connect by using byebug -R localhost:<port>.
            # If you plan on hitting the breakpoint again, leave it open; weird things happen when you close it.
            RFlow.logger.info "Opening debugger on port #{8989 + worker.index}"
            remote_byebug 'localhost', 8989 + worker.index
          end

          response_port.send_message(RFlow::Message.new('RFlow::Message::Data::HTTP::Response').tap do |m|
            m.provenance = message.provenance
            m.data.content = response.data
          end)

          @response_counter += 1
        ensure
          Log4r::MDC.remove('provenance')
        end
      end
    end
  end
end
