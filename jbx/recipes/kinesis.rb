# For setting up and running the java to support Kinesis Streams
service "kinesis" do
    supports :status => true, :restart => true
    start_command "/usr/bin/java -cp \"/vagrant/www/jbx/application/modules/consumer/jars/*\" software.amazon.kinesis.multilang.MultiLangDaemon --properties-file /vagrant/www/jbx/application/modules/consumer/config/config.properties >> /var/log/jbx-kinesis.log"
    restart_command "kill $(ps aux | grep java|grep kinesis | awk '{print $2}') && mv /var/log/jbx-kinesis.log /var/log/jbx-kinesis.log.old && /usr/bin/java -cp \"/vagrant/www/jbx/application/modules/consumer/jars/*\" software.amazon.kinesis.multilang.MultiLangDaemon --properties-file /vagrant/www/jbx/application/modules/consumer/config/config.properties >> /var/log/jbx-kinesis.log"
    status_command "ps aux|grep java|grep kinesis"
    action [ :enable, :start ]
end