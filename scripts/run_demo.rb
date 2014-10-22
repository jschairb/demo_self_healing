require 'bundler/setup'
require 'colorize'
require 'restclient'
require 'json'

URL = 'http://service.xmag.us'

def get_response
  RestClient.get URL
end

def output_response(response)
  body = JSON.parse(response.body)
  external_code = body.fetch('external_response', {}).fetch('status', 500).to_i

  line = "#{response.code} - #{external_code} - #{body['resolved_hostname']}"
  color = external_code == 200 ? :green : :red
  puts line.colorize(color)
end


if ARGV[0] == "loop"
  while true
    output_response(get_response)
  end
else
  output_response(get_response)
end
