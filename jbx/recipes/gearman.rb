include_recipe "configure"

if node["jbx"]["gearman"]
  # Delete the config script if it isnt a symlink to processing
  file "/etc/gearman-manager/config.ini" do
    action :delete
    not_if { File.symlink?("/etc/gearman-manager/config.ini") }
  end

  # Symlink our config script
  edit_resource(:link, "/etc/gearman-manager/config.ini") do
    to "#{node["jbx"]["path"]}/application/modules/processing/config/config.ini"
    action :create
    owner node[:user]
    group node[:user]
    notifies :restart, "service[gearman-manager.service]", :delayed
    not_if { File.symlink?("/etc/gearman-manager/config.ini") }
  end

  consul_definition "gearman" do
    type "service"
    parameters(
      port: 4730,
      tags: ["gearman"],
      check: {
        interval: "5s",
        timeout: "3s",
        args: [
          node["consul"]["service"]["config_dir"] + "/gearman_check.php",
          node["gearman"]["host"],
        ],
      },
    )
    notifies :reload, "service[consul.service]", :delayed
  end
else
  consul_definition "gearman" do
    action :delete
  end
end
