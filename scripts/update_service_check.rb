#!/usr/bin/env ruby

datacenter = ARGV[0]
status     = ARGV[1]

CURL_CHECK_COMMAND = %q[curl -X PUT -d '{"Datacenter": "DFW", "Node": "external-%{datacenter}.xmag.us", "Address": "http://external-%{datacenter}.xmag.us", "Check": {"Node": "external-%{datacenter}.xmag.us", "ID": "http:external:%{datacenter}", "Name": "http status", "Notes": "Non-200 responses cause failure", "Status": "%{status}", "ServiceID": "external:%{datacenter}"}}}' http://sd.xmag.us/v1/catalog/register]

command = CURL_CHECK_COMMAND % { datacenter: datacenter, datacenter_upcased: datacenter.upcase, status: status }

puts command

exec command
