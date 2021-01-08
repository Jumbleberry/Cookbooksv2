ohai_plugin "nvme" do
  path "/etc/chef/ohai_plugins/"
  compile_time true
end

if node.attribute?(:nvme)
  directory "/" + node[:nvme][:name] do
    owner "root"
    group "root"
    mode "0755"
    action :create
  end

  execute "format_" + node[:nvme][:name] do
    command "mkfs -t xfs " + node[:nvme][:path]
    not_if { node[:nvme].attribute?(:fs_type) }
  end

  mount "/" + node[:nvme][:name] do
    device node[:nvme][:path]
    fstype node[:nvme][:fs_type] || "xfs"
    action :mount
  end
end
