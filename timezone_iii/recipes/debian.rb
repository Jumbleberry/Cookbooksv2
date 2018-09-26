#
# Cookbook:: timezone_iii
# Recipe:: debian
#
# Copyright:: 2017, Corey Hemminger
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set timezone for Debian family:  Put the timezone string in plain text in
# /etc/timezone and then re-run the tzdata configuration to pick it up.

TIMEZONE_FILE = '/etc/timezone'.freeze

file 'remove-wrong-localtime-link' do
  path '/etc/localtime'
  action :delete
  manage_symlink_source false
  only_if {
    File.exist?('/etc/localtime') &&
      File.read("/usr/share/zoneinfo/#{node['timezone_iii']['timezone']}") != File.read('/etc/localtime')
  }
end

template TIMEZONE_FILE do
  source 'timezone.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[dpkg-reconfigure-tzdata]'
end

execute 'dpkg-reconfigure-tzdata' do
  command '/usr/sbin/dpkg-reconfigure -f noninteractive tzdata'
  action :nothing
end

# Certain values get normalized by dpkg-reconfigure, causing this recipe to try
# to rewrite the file over and over.  This raises a red flag in such a case.
log 'if-unexpected-timezone-change' do
  message "dpkg-reconfigure is amending the value #{node['timezone_iii']['timezone'].inspect} in #{TIMEZONE_FILE}"
  level :warn
  not_if { ::File.read(TIMEZONE_FILE).chomp == node['timezone_iii']['timezone'] }
  action :nothing
  subscribes :write, 'execute[dpkg-reconfigure-tzdata]', :immediately
end
