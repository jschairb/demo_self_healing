require 'securerandom'
require 'socket'

require 'bundler/setup'
require 'json'
require 'sinatra'

$FAILING = false

before %r{^(?!/toggle$)} do
  halt 500, { msg: "An error has occurred" }.to_json if $FAILING
end

post '/toggle' do
  $FAILING = !$FAILING
  { failing: $FAILING }.to_json
end

get '/' do
  { id: SecureRandom.hex,
    hostname: Socket.gethostname,
    timestamp: Time.now.strftime('%Y%m%d%H%M%S (%z)') }.to_json
end
