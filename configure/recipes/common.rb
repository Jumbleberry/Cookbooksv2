include_recipe cookbook_name + "::user"
include_recipe cookbook_name + "::ipaddress"
include_recipe "dnsmasq"
include_recipe "opsworks_stack_state_sync"
include_recipe "timezone_iii"
include_recipe "ntp"

if !node.attribute?(:ec2)
  include_recipe "root_ssh_agent::ppid"

  group node["user"] do
    append true
    action :manage
    members ["www-data"]
  end
else
  group "www-data" do
    append true
    action :manage
    members [node["user"]]
  end
end

ssh_known_hosts_entry "github.com"
