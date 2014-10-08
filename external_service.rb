require 'securerandom'
require 'socket'

require 'bundler/setup'
require 'json'
require 'sinatra'

$FAILURE_RATE  = 0
$FAILURE_SCALE = 100

module FailureRate
  def self.to_json
    { rate: $FAILURE_RATE,
      scale: $FAILURE_SCALE,
      timestamp: Timestamp.now }.to_json
  end
end

module Timestamp
  def self.now
    Time.now.strftime('%Y%m%d%H%M%S (%z)')
  end
end

class Token
  attr_reader :timestamp, :token

  def initialize(token = nil)
    @token     = token ||= SecureRandom.hex
  end

  def hostname
    @hostname ||= Socket.gethostname
  end

  def timestamp
    @timestamp ||= Timestamp.now
  end

  def to_json
    { id: token,
      hostname: hostname,
      timestamp: timestamp }.to_json
  end
end

before %r{^(?!/failure_rate$)} do
  halt_500 = $FAILURE_RATE >= rand($FAILURE_SCALE)
  halt 500, { msg: "An error has occurred" }.to_json if halt_500
end

get '/failure_rate' do
  FailureRate.to_json
end

post '/failure_rate' do
  # { 'rate': 10 }
  rate_value    = params['rate'].to_i  || $FAILURE_RATE
  $FAILURE_RATE = rate_value

  FailureRate.to_json
end

get '/token' do
  token = Token.new
  token.to_json
end
