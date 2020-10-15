# For setting up and running the java to support Kinesis Streams
if node["jbx"].attribute?(:consumers)
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
            RestartSec: 10,
          },
          Install: {
            WantedBy: "multi-user.target",
          },
        }
      )
      action [:create] + (node["configure"]["services"][service] || %i{stop disable})
    end
  end
end
