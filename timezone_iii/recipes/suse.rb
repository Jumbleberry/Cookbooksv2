#
# Cookbook:: timezone_iii
# Recipe:: suse
#
# Copyright:: 2017, Brad Beveridge
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

# This sets the timezone on SUSE distributions

v_major, _v_minor = node['platform_version'].split(/\./)
src_template = v_major.to_i == 11 ? 'suse/clock.suse11.erb' : 'suse/clock.erb'

template '/etc/sysconfig/clock' do
  source src_template
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[tz-update]'
end

execute 'tz-update' do
  command "/usr/sbin/zic -l #{node['timezone_iii']['timezone']}"
  action :nothing
end
