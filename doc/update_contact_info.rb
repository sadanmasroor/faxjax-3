#!/usr/bin/env ruby -wKU
#  run in ./script/runner 0 updates last_modified timestamp
ci = HomeHelper::ContactInfo.from_yaml
ci.update_modified
ci.dump_yaml
puts "updated to #{ci.last_modified}"
puts "now 'git add .'"