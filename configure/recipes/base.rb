include_recipe cookbook_name + "::user"
include_recipe cookbook_name + "::ipaddress"
include_recipe "etc_environment"
include_recipe "dnsmasq"
include_recipe "opsworks_stack_state_sync"
include_recipe "timezone_iii"
include_recipe "ntp"

ssh_known_hosts_entry "github.com"

if node.attribute?(:ec2)
  group "www-data" do
    action :manage
    members ["ubuntu"]
  end
else
  group node["user"] do
    action :manage
    members ["www-data"]
  end

  include_recipe "root_ssh_agent::ppid"
end
