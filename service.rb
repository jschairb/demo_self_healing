
require 'bundler/setup'
require 'json'
require 'rest_client'
require 'sinatra'
require 'common'

require 'resolv'
class ResolvDNSAdapter
  attr_reader :nameserver

  def initialize(nameserver)
    @dns        = Resolv::DNS.new(nameserver: nameserver)
    @nameserver = nameserver
  end

  def cname(hostname)
    @dns.getresources(hostname, Resolv::DNS::Resource::IN::CNAME).first.name
  end
end

class ExternalServiceHostname
  attr_reader :hostname

  def initialize(hostname, dns)
    @hostname = hostname
    @dns     = dns
  end

  def resolved
    dns.cname(hostname)
  end

  def to_s
    hostname
  end
end

class ExternalResponse
  attr_reader :attributes

  def initialize(external_service)
    @external_service = external_service
  end

  def attributes
    @attributes ||= {
      external_hostname: external_hostname,
      external_resolved_hostname: external_resolved_hostname,
      hostname: Hostname.local_hostname,
      timestamp: Timestamp.now }
  end

  def external_hostname
    external_service.hostname
  end

  def external_resolved_hostname
    external_service.resolved_hostname
  end

  def external_response
    attributes[:external_response] ||= get_external_response
  end

  def fetch
    external_response
  end

  def get_external_response
    response = RestClient.get(external_service.token_url)
    raise InvalidResponse unless response.code == 200
    JSON.parse(response.body)
  rescue JSON::ParserError => error
    error
  end

  def to_json
    attributes.to_json
  end
end

class ExternalService
  def initialize(hostname, resolver)
    @hostname = ExternalServiceHostname.new(hostname, resolver)
  end

  def resolved_hostname
    @hostname.resolved
  end

  def token_url
    "#{resolved_hostname}/token"
  end
end

require 'yaml'
CONFIG   = YAML.load_file("config.yml")
RESOLVER = ResolvDNSAdapter.new(CONFIG[:nameserver])

configure do
  set :external_service, ExternalService.new(CONFIG[:external_hostname],
                                             resolver)
end

get '/' do
  response = ExternalResponse.new(external_service)
  response.fetch
  response.to_json
end
