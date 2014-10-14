require 'bundler/setup'
require 'json'
require 'rest_client'
require 'sinatra'

require 'common'

$EXTERNAL_URL = 'http://external-dfw.xmag.us'

class ExternalResponse
  attr_reader :attributes

  def attributes
    @attributes ||= {
      external_url: $EXTERNAL_URL,
      hostname: Hostname.local_hostname,
      timestamp: Timestamp.now }
  end

  def external_response
    attributes[:external_response] ||= get_external_response
  end

  def fetch
    external_response
  end

  def get_external_response
    response = RestClient.get("#{$EXTERNAL_URL}/token")
    raise InvalidResponse unless response.code == 200
    JSON.parse(response.body)
  rescue JSON::ParserError => error
    error
  end

  def to_json
    attributes.to_json
  end
end

get '/' do
  response = ExternalResponse.new
  response.fetch
  response.to_json
end
