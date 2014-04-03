RFlow::Configuration::RubyDSL.configure do |config|
  config.setting('rflow.log_level', 'DEBUG')
  config.setting('rflow.application_directory_path', '.')
  config.setting('rflow.application_name', 'httplogger')

  config.component 'http_server', 'RFlow::Components::HTTP::Server'
  config.component 'http_responder', 'RFlow::Components::HTTPResponder'
  config.component 'http_to_raw', 'RFlow::Components::HTTPToRaw'
  config.component 'http_log', 'RFlow::Components::File::OutputRawToFiles', {
    'directory_path' => './output/',
    'file_name_prefix' => 'o.',
    'file_name_suffix' => '.http',
  }

  # Server -> Responder -> Server
  config.connect 'http_server#request_port' => 'http_responder#request_port'
  config.connect 'http_responder#response_port' => 'http_server#response_port'

  # Log the messages
  config.connect 'http_server#request_port' => 'http_to_raw#http_port'
  config.connect 'http_responder#response_port' => 'http_to_raw#http_port'
  config.connect 'http_to_raw#raw_port' => 'http_log#raw_port'
end
