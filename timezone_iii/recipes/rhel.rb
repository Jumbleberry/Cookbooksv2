#
# Cookbook:: timezone_iii
# Recipe:: rhel
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

# This recipe sets the timezone on EL 6 and older (RedHat Enterprise Linux,
# CentOS, etc.)
#
# If it is being run on EL 7 or newer, the recipe will be skipped and
# the "rhel7" recipe will be included instead.

template '/etc/sysconfig/clock' do
  source 'rhel/clock.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[tzdata-update]'
end

execute 'tzdata-update' do
  command '/usr/sbin/tzdata-update'
  action :nothing
  # Amazon Linux doesn't have this command!
  only_if { ::File.executable?('/usr/sbin/tzdata-update') }
end
