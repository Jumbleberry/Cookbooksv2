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
      action [:create] + (node["configure"]["services"][service] || %i{stop disable})
      subscribes :restart, "execute[/bin/bash #{node["jbx"]["path"]}/deploy.sh]", :delayed if (node["configure"]["services"][service] || []).include?("start")
    end
  end
end
