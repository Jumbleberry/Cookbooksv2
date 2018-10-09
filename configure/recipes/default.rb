include_recipe cookbook_name + '::ipaddress'
include_recipe 'dnsmasq'
include_recipe 'opsworks_stack_state_sync'
include_recipe 'timezone_iii'
include_recipe 'ntp'

ssh_known_hosts_entry 'github.com'