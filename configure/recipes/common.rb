include_recipe cookbook_name + "::user"
include_recipe cookbook_name + "::ipaddress"
include_recipe "etc_environment"
include_recipe "dnsmasq"
include_recipe "opsworks_stack_state_sync"
include_recipe "timezone_iii"
include_recipe "ntp"

if !node.attribute?(:ec2)
  include_recipe "root_ssh_agent::ppid"
end

ssh_known_hosts_entry "github.com"

directory "#{node["etc"]["passwd"][node[:user]]["dir"]}/.ssh" do
  owner node[:user]
  group node[:user]
  recursive true
end
cookbook_file "#{node["etc"]["passwd"][node[:user]]["dir"]}/.ssh/config" do
  source "config"
  owner node[:user]
  group node[:user]
  mode "0600"
  action :create
end

group node["user"] do
  action :manage
  members ["www-data"]
end
