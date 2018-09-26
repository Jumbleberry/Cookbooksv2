#
# Cookbook:: timezone_iii
# Recipe:: pld
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

# Set timezone for PLD family:  Put the timezone string in plain text in
# /etc/sysconfig/timezone and then re-run the timezone service to pick it up.

template '/etc/sysconfig/timezone' do
  source 'pld/timezone.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :reload, 'service[timezone]'
end

service 'timezone' do
  action :nothing
end
