include_recipe cookbook_name + "::user"
include_recipe cookbook_name + "::ipaddress"
include_recipe cookbook_name + "::packages"
include_recipe "opsworks_stack_state_sync"
include_recipe "timezone_iii"
include_recipe "timezone_iii::linux_generic"
include_recipe "ntp"

unless node.attribute?(:ec2)
  include_recipe "root_ssh_agent::ppid"
end

ssh_known_hosts_entry "github.com"
