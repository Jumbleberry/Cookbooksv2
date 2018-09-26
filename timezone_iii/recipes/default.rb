#
# Cookbook:: timezone_iii
# Recipe:: default
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

case node['os']
  when 'linux'
    package value_for_platform_family(
      gentoo:  'timezone-data',
      suse:    'timezone',
      default: 'tzdata'
    )
    case node['platform_family']
      when 'suse'
        include_recipe "timezone_iii::#{node['platform_family']}"
      when 'rhel', 'fedora'
        include_recipe node['platform_version'].split('.')[0].to_i >= 7 ? 'timezone_iii::rhel7' : 'timezone_iii::rhel'
      when 'amazon'
        include_recipe "timezone_iii::#{node['platform_family']}"
      when 'debian', 'pld'
        include_recipe "timezone_iii::#{node['platform_family']}"
      else
        # Load the generic Linux recipe if there's no better known way to change the
        # timezone.  Log a warning (unless this is known to be the best way on a
        # particular platform).
        message = "Linux platform '#{node['platform']}' is unknown to this recipe; using generic Linux method"
        log message do
          level :warn
          not_if { %w[centos gentoo rhel amazon].include? node['platform_family'] }
          only_if { node['os'] == 'linux' }
        end
        include_recipe 'timezone_iii::linux_generic'
    end
  when 'windows'
    include_recipe 'timezone_iii::windows'
  else
    raise 'OS Unsuported'
end
