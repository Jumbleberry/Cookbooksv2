# For setting up and running the java to support Kinesis Streams
if node["jbx"].attribute?(:consumers) && node["jbx"]["path"] == "/var/www/jbx"
  node["jbx"]["consumers"].each do |service, config|
    systemd_unit service + ".service" do
      content(
        {
          Unit: {
            Description: "KCL Service for " + service,
          },
          Service: {
            Type: "simple",
            ExecStart: "/usr/bin/java -cp \"#{node["jbx"]["path"]}/application/modules/consumer/jars/*\" software.amazon.kinesis.multilang.MultiLangDaemon --properties-file #{node["jbx"]["path"]}/application/modules/consumer/config/#{config}",
            User: node[:user],
            Restart: "on-failure",
            RestartSec: 5,
          },
          Install: {
            WantedBy: "multi-user.target",
          },
        }
      )
      triggers_reload true
      action [:create] + (node["configure"]["services"][service] || %i{stop disable})
      subscribes :restart, "execute[/bin/bash #{node["jbx"]["path"]}/deploy.sh]", :delayed if (node["configure"]["services"][service] || []).include?("start")
    end unless node[:container]

    logrotate_app service do
      path File.dirname(node["php"]["logfile"]) + "/#{service}.log"
      enable node["php"]["logrotate"]
      frequency "daily"
      rotate node["php"]["logrotate_days"]
      create "0644 #{node["user"]} adm"
      options node["php"]["logrotate_options"]
    end
  end
end
