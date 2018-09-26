#
# Cookbook:: timezone_iii
# Recipe:: amazon
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

# Amazon recommends editing /etc/sysconfig/clock as in the rhel recipe, but then
# creating a link for /etc/localtime.  It doesn't have a tzdata-update command
# like the other flavors of RHEL.
#
# Source: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html
# (as of 2014-12-18)

include_recipe 'timezone_iii::linux_generic'
include_recipe 'timezone_iii::rhel'
