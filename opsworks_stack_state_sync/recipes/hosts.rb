require "resolv"

template "/etc/hosts" do
  source "hosts.erb"
  mode "0644"
  variables(
    localhost_name: node.attribute?(:opsworks) ? node[:opsworks][:instance][:hostname] : node[:hostname],
    nodes: node.attribute?(:opsworks) ? search(:aws_opsworks_instance, "hostname:*") : search(:node, "name:*"),
  )
end

ohai "hostname" do
  plugin "hostname"
  action :reload
end
