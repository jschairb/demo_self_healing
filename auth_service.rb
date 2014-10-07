require 'securerandom'

require 'bundler/setup'
require 'json'
require 'sinatra'

$FAILING = false
$TOKENS = []

before %r{^(?!/toggle$)} do
  halt 500, { msg: "An error has occurred" }.to_json if $FAILING
end

get '/' do
  { tokens: $TOKENS.collect { |t| { id: t } } }.to_json
end

post '/toggle' do
  $FAILING = !$FAILING
  { toggle: $FAILING }.to_json
end

get '/tokens/:id' do
  halt 404, { msg: "Not found" }.to_json unless $TOKENS.include?(params[:id])
  { id: params[:id] }.to_json
end

post '/tokens' do
  token = SecureRandom.hex
  $TOKENS << token
  { id: token }.to_json
end
