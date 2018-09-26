cookbook_name = 'configure'

default[cookbook_name]['plugin_path'] = '/etc/chef/ohai_plugins'

default['timezone_iii']['timezone'] = node['tz']