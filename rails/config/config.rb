RFlow::Configuration::RubyDSL.configure do |config|
  config.setting 'rflow.log_level', 'DEBUG'
  config.setting 'rflow.application_directory_path', '..'
  config.setting 'rflow.application_name', 'railsapp'

  # Set up the necessary components
  config.component 'http_server', 'RFlow::Components::HTTP::Server', {
    'listen' => '0.0.0.0',
  }

  if true
    # Handle HTTP messages directly like Rails does
    config.shard 'rails', :process => 10 do |shard|
      shard.component 'rails_app', 'RFlow::Components::Rails3App'
    end

    # Server -> Responder -> Server - send the http responses
    config.connect 'http_server#request_port' => 'rails_app#request_port'
    config.connect 'rails_app#response_port' => 'http_server#response_port'
  else
    # A more complicated topology as a many-to-many example
    config.shard 'envelope', :process => 3 do |shard|
      shard.component 'remove_envelope', 'RFlow::Components::RemoveEnvelope'
      shard.component 'add_envelope', 'RFlow::Components::AddEnvelope'
    end

    config.shard 'raw', :process => 10 do |shard|
      shard.component 'raw_app', 'RFlow::Components::RawApp'
    end

    # Server -> RemoveEnvelope -> Responder -> Add Envelope -> Server
    config.connect 'http_server#request_port' => 'remove_envelope#request_port'
    config.connect 'remove_envelope#content_port' => 'raw_app#request_port'
    config.connect 'raw_app#response_port' => 'add_envelope#content_port'
    config.connect 'add_envelope#response_port' => 'http_server#response_port'
  end
end
