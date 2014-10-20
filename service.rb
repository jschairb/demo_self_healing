require 'bundler/setup'
require 'json'
require 'resolv'
require 'rest_client'
require 'sinatra'
require 'socket'

require 'yaml'
CONFIG   = YAML.load_file("config.yml")

helpers do
  def get_external_response(url)
    response = begin
      RestClient.get(url)
    rescue RestClient::InternalServerError
      require 'ostruct'
      OpenStruct.new(code: 500, body: '{"msg": "there was an error"}')
    end

    {}.tap do |external_response|
      external_response[:status] = response.code

      parsed_body = begin
                      JSON.parse(response.body)
                    rescue JSON::ParserError => error
                      { error: response.body }
                    end
      external_response.merge!(parsed_body)
    end
  end

  def mark_http_check_critical(url)
    region = url.gsub(/http:\/\/external-/, "").gsub(".xmag.us", "")
    `ruby scripts/update_service_check.rb #{region} critical`
  end

  def resolved_hostname_cname(nameserver, hostname)
    dns = Resolv::DNS.new(nameserver: nameserver)
    dns.getresources(hostname, Resolv::DNS::Resource::IN::CNAME).first.name.to_s
  end
end

get '/' do
  external_hostname = resolved_hostname_cname(CONFIG[:nameserver],
                                              CONFIG[:external_hostname])

  external_response = get_external_response(external_hostname)
  remove_url_from_consul if external_response.fetch(:status, 200).to_i != 200
  {
    local_hostname: Socket.gethostname,
    resolved_hostname: external_hostname,
    timestamp: Time.now.strftime('%Y%m%d%H%M%S (%z)'),
    external_response: external_response
  }.to_json
end
