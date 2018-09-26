#
# Cookbook:: timezone_iii
# Attribute:: default
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

# Use universal time if no other timezone is specified
default['timezone_iii']['timezone'] = value_for_platform_family(
  debian: 'Etc/UTC',
  default: 'UTC'
)

# Platform Family:     RHEL
# Type:                string(true,false)

# When 'true', write "UTC=true" line in /etc/sysconfig/clock.
default['timezone_iii']['clock_utc'] = nil

# Path to tzdata directory
default['timezone_iii']['tzdata_dir'] = '/usr/share/zoneinfo'

# Path to file used by kernel for local timezone's data
default['timezone_iii']['localtime_path'] = '/etc/localtime'

# Whether to use a symlink to tzdata (instead of copying).
# Used only in the linux-default recipe.
default['timezone_iii']['use_symlink'] = false

# Platform:            SUSE
# Type:                string(-u,--utc,--localtime)
# ServiceRestart:      boot.clock
# Command:             /sbin/refresh_initrd
#
# Set to "-u" if your system clock is set to UTC, and to "--localtime"
# if your clock runs that way.
#
default['timezone_iii']['hwclock'] = '--localtime'

# Platform:            SUSE
# Type:                yesno
# Default:             yes
# Description: Write back system time to the hardware clock

# Is set to "yes" write back the system time to the hardware
# clock at reboot or shutdown. Usefull if hardware clock is
# much more inaccurate than system clock.  Set to "no" if
# system time does it wrong due e.g. missed timer interrupts.
# If set to "no" the hardware clock adjust feature is also
# skipped because it is rather useless without writing back
# the system time to the hardware clock.
#
default['timezone_iii']['systohc'] = 'yes'
