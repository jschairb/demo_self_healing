#!/usr/bin/env ruby

datacenter = ARGV[0]

CURL_CHECK_COMMAND = %q[curl -X POST -d '{}' http://external-%{datacenter}.xmag.us/toggle]

command = CURL_CHECK_COMMAND % { datacenter: datacenter }

puts command

exec command
