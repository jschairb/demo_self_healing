module Timestamp
  def self.now
    Time.now.strftime('%Y%m%d%H%M%S (%z)')
  end
end

module Hostname
  require 'socket'

  def self.local_hostname
    Socket.gethostname
  end
end
