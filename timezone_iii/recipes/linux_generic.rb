#
# Cookbook:: timezone_iii
# Recipe:: linux_generic
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

# Generic timezone-changing method for Linux that should work for any distro
# without a platform-specific method.

timezone_data_file = File.join(node['timezone_iii']['tzdata_dir'], node['timezone_iii']['timezone'])
localtime_path = node['timezone_iii']['localtime_path']

ruby_block 'confirm timezone' do
  block do
    raise "Can't find #{timezone_data_file}!"
  end
  not_if { File.exist?(timezone_data_file) }
end

if node['timezone_iii']['use_symlink']
  link localtime_path do
    to timezone_data_file
    owner 'root'
    group 'root'
  end

else
  file localtime_path do
    content File.open(timezone_data_file, 'rb').read
    owner 'root'
    group 'root'
    mode '0644'
    not_if { File.symlink?(localtime_path) && Chef::Log.error("You must remove symbolic link at #{localtime_path} or set attribute ['timezone']['use_symlink'] = true") }
  end
end
