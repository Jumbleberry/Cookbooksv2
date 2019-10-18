include_recipe "configure::user"
include_recipe "configure::ipaddress"

if node["jbx"]["gearman"]
  # Delete the config script if it isnt a symlink to processing
  file "/etc/gearman-manager/config.ini" do
    action :delete
    not_if { File.symlink?("/etc/gearman-manager/config.ini") }
  end

  # Symlink our config script
  link "/etc/gearman-manager/config.ini" do
    to "#{node["jbx"]["path"]}/application/modules/processing/config/config.ini"
    action :create
    owner node[:user]
    group node[:user]
  end

  service "jbx.gearman-job-server" do
    service_name "gearman-job-server"
    action [:enable, :start]
  end
  service "jbx.gearman-manager" do
    service_name "gearman-manager"
    action [:enable, :start]
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
          node["ipaddress"],
        ],
      },
    )
    notifies :reload, "service[consul]", :delayed
  end
else
  service "jbx.gearman-job-server" do
    service_name "gearman-job-server"
    action [:stop, :disable]
  end
  service "jbx.gearman-manager" do
    service_name "gearman-manager"
    action [:stop, :disable]
  end
  consul_definition "gearman" do
    action :delete
  end
end
