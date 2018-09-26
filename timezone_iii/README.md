[![Chef cookbook](https://img.shields.io/cookbook/v/timezone_iii.svg)]()
[![Code Climate](https://codeclimate.com/github/Stromweld/timezone_iii/badges/gpa.svg)](https://codeclimate.com/github/Stromweld/timezone_iii)
[![Issue Count](https://codeclimate.com/github/Stromweld/timezone_iii/badges/issue_count.svg)](https://codeclimate.com/github/Stromweld/timezone_iii)

# timezone_iii

The Timezone III cookbook contains recipes for installing the latest tzdata (a.k.a. IANA or Olson) timezone database and setting the timezone on your system.  It is a fork of the [timezone-ii cookbook by Lawrence Gilbert.](https://supermarket.chef.io/cookbooks/timezone-ii).

## Requirements

Amazon Linux should use chef-client 13. The default recipe picks the correct recipe to run based on node['platform_family']. In chef-client 13 ohai assigns amazon as it's own platform_family instead of rhel in previous chef-clients.

This cookbook is known to work with:

* Amazon Linux
* CentOS and RHEL
* Debian
* Fedora
* Gentoo
* PLD Linux
* Ubuntu
* Windows

It _should_ work with any OS that uses the IANA/Olson timezone database and stores local timezone data in /etc/localtime (the only OS I know of that does _not_ do this is MS Windows).  However, some OSs not mentioned above have their own system utility for setting the timezone, and this may overwrite the changes made by this cookbook.

## Attributes

| Attribute | Default | Comment |
| -------------  | -------------  | -------------  |
| ['timezone_iii']['timezone'] | 'value_for_platform_family(debian: 'Etc/UTC', default: 'UTC')' | String, timezone to set OS to |
| ['timezone_iii']['clock_utc'] | `nil` | String(true,false), UTC setting in /etc/sysconfig/clock (RHEL family only) |
| ['timezone_iii']['tzdata_dir'] | '/usr/share/zoneinfo' | String, the path to the root of the tzdata files; the default value is for most known distributions of Linux |
| ['timezone_iii']['localtime_path'] | '/etc/localtime' | String, the path to the file used by the kernel to read the local timezone's settings; the default works for Linux and other *ix variants |
| ['timezone_iii']['use_symlink'] | false | Boolean, whether to use a symlink into the tzdata tree rather than make a copy of the appropriate timezone data file (amazon and linux_generic recipes only) |

## Usage

Set the ['timezone_iii']['timezone'] attribute to your desired timezone and include the "timezone_iii" recipe in your node's run list:

    {
      "name": "my_node",
      "timezone_iii" {
        "timezone": "Africa/Timbuktu"
      },
      "run_list": [
        "recipe[timezone_iii]"
      ]
    }

### timezone_iii::default

The default recipe will first install or upgrade the IANA/Olson timezone database package for your OS (`timezone-data` on Gentoo, `tzdata` on all other linux platforms). Then it will call one of the recipes below according to your node's platform.

### timezone_iii::amazon

This changes the timezone on Amazon Linux by:

1. including the "timezone_iii::linux_generic" recipe then;
2. including the "timezone_iii::rhel" recipe.

Refer to the sections for those recipes for details.

### timezone_iii::debian

This changes the timezone on Debian-family platforms by:

1. writing the value of `['timezone_iii']['timezone']` to `/etc/timezone` then;
2. calling `dpkg-reconfigure -f noninteractive tzdata`;
3. if `dpkg-reconfigure` amends the timezone value (e.g. by changing "UTC" to "Etc/UTC" or "EET" to "Europe/Helsinki"), it logs a warning.

Only the `['timezone_iii']['timezone']` attribute is used; all others are ignored.

### timezone_iii::linux_generic

This changes the time on all OSs without a more specific recipe. It assumes that the kernel gets data on the local timezone from `/etc/localtime`. (This is true for FreeBSD as well as Linux, so "linux_generic" is a bit of a misnomer.)

What this recipe does:

1. verifies that the value of `['timezone_iii']['timezone']` corresponds with a timezone data file under the directory specified in `timezone.tzdata_dir` (default:`/usr/share/zoneinfo`), then;
2. creates a copy of or symbolic link to that data file in the path specified in `timezone.localtime_path` (default: `/etc/localtime`).

The truthiness of `timezone.use_symlink` (default: `false`) determines whether a symlink or a copy is made.

### timezone_iii::pld

This changes the timezone on PLD Linux. It writes the appropriate timezone configuration file, making use of the `['timezone_iii']['timezone']` and `['timezone_iii']['tzdata_dir']` attributes. Other attributes are ignored.

### timezone_iii::rhel

This changes the timezone on RedHat Enterprise Linux (RHEL) and RHEL-family platforms such as CentOS.  It is intended only for versions prior to 7.0, but should the recipe be called on a system with version 7.0 or newer, it will automatically include the "timezone_iii::rhel7" recipe and do nothing else.

This recipe updates the `/etc/sysconfig/clock` file with the value of the `['timezone_iii']['timezone']` attribute, then calls `tzdata-update` (if available) to change the timezone. All node attributes other than `['timezone_iii']['timezone']` are ignored.

### timezone_iii::rhel7

This changes the timezone on EL 7 platforms by calling `timedatectl set-timezone` with the value of `['timezone_iii']['timezone']`.

Only the `['timezone_iii']['timezone']` attribute is used; all others are ignored.

### timezone_iii::windows

This changes the timezone on windows platforms by calling `tzutil.exe` with the value of `['timezone_iii']['timezone']`. To get a list of timezones to use with windows you can run the command `tzutil.exe /l | more` on the command line and use the standard name under the offset info.

Only the `['timezone_iii']['timezone']` attribute is used; all others are ignored.

## Contributing

1. Fork the [repository on GitHub](https://github.com/Stromweld/timezone_iii);
2. Write your change;
3. If at all possible, write tests for your change and ensure they all pass;
4. Submit a pull request using GitHub.

## Acknowledgements

Thanks to:

* Larry Gilbert, for launching the timezone-ii cookbook
* James Harton, for launching the timezone cookbook
* Elan Ruusamäe, for PLD support
* Mike Conigliaro, for bringing testing up to date
* "fraD00r4", for RHEL/CentOS support

## License and Authors

* Copyright © 2010 James Harton <james@sociable.co.nz>
* Copyright © 2013-2015 Lawrence Leonard Gilbert <larry@L2G.to>
* Copyright © 2013 Elan Ruusamäe <glen@delfi.ee>
* Copyright © 2013 fraD00r4 <frad00r4@gmail.com>
* Copyright © 2017 Corey Hemminger <hemminger@hotmail.com>

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.  You may obtain a copy of the
License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License.
