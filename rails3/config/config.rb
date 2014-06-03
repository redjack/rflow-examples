RFlow::Configuration::RubyDSL.configure do |config|
  config.setting 'rflow.log_level', 'DEBUG'
  config.setting 'rflow.application_directory_path', '..'
  config.setting 'rflow.application_name', 'rails3app'

  # Set up the necessary components
  config.component 'http_server', 'RFlow::Components::HTTP::Server'

  config.shard 'rails3', :process => 10 do |shard|
    shard.component 'rails3_app', 'RFlow::Components::Rails3App'
  end

  # Server -> Responder -> Server - send the http responses
  config.connect 'http_server#request_port' => 'rails3_app#request_port'
  config.connect 'rails3_app#response_port' => 'http_server#response_port'
end
