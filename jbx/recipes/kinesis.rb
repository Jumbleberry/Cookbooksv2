# For setting up and running the java to support Kinesis Streams
systemd_unit "jbx-kinesis.service" do
    content(
        {
            Unit: { 
                Description: 'Enables the JBX java processes for Kinesis data streaming',
            },
            Service: {
                Type: 'simple',
                ExecStart: '/usr/bin/java -cp "/var/www/jbx/application/modules/consumer/jars/*" software.amazon.kinesis.multilang.MultiLangDaemon --properties-file /var/www/jbx/application/modules/consumer/config/config.properties',
                User: node[:user],
                Restart: 'on-failure',
                RestartSec: 10,
            },
            Install: {
                WantedBy: 'multi-user.target',
            }
        }
    )
    action [:create, :enable]
end