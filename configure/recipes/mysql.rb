if node["environment"] == "dev" && (node["configure"]["services"]["mysql"] && (node["configure"]["services"]["mysql"].include? "start"))
  # Fixes poor IO performance on dev/ci when seeding tables
  node["block_device"].select { |device, info| device =~ /^.d.$/ && info["size"].to_i > 0 }.each do |device, info|
    execute "scheduler-#{device}" do
      command "echo 'noop' > /sys/block/#{device}/queue/scheduler"
      only_if "grep -F 'noop' /sys/block/#{device}/queue/scheduler"
    end
  end

  replace_or_add "mysql.service" do
    path "/lib/systemd/system/mysql.service"
    pattern ".*LimitNOFILE.*"
    line "LimitNOFILE = 100000"
    notifies :run, "execute[mysql systemctl daemon-reload]", :immediate unless node[:container]
  end

  execute "mysql systemctl daemon-reload" do
    command "systemctl daemon-reload"
    action :nothing
  end

  # Copy config file
  template "/etc/mysql/my.cnf" do
    manage_symlink_source true
    source "my.cnf.erb"
    mode "0644"
  end
    
  directory '/var/log/mysql' do
    recursive true
    owner "mysql"
    group "mysql"
    mode "0755"
    action :create
  end

  bak = "/var/lib/mysql.bak"
  if node.attribute?(:nvme)
    nvme = "/#{node["nvme"]["name"]}/mysql"

    service "mysql" do
      provider Chef::Provider::Service::Systemd
      action :nothing
    end

    # Backup mysql & disable apparmor as it wont allow reads from /nvme*
    execute "backup_mysql" do
      command <<-EOH
        mv /var/lib/mysql #{bak} \
          && sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/ \
          && sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld
      EOH
      notifies :stop, "service[mysql]", :before
      not_if { ::File.directory?(bak) }
    end

    directory nvme do
      recursive true
      owner "mysql"
      group "mysql"
      mode "0755"
      action :create
    end


    link "/var/lib/mysql" do
      to nvme
      owner "mysql"
      group "mysql"
      action :create
    end

    # Copy mysql to nvme dir
    execute "restore_mysql" do
      command "rsync -avh #{bak}/ #{nvme}/"
      not_if { ::File.exists?("#{nvme}/ibdata1") }
    end

    cron "Backup MySQL NVMe" do
      command "[ -f #{nvme}/ibdata1 ] && (rsync -avh --delete #{nvme}/ #{bak}/ || rsync -avh --ignore-errors --delete #{nvme}/ #{bak}/)"
      minute "*/15"
    end

    cron "Restore MySQL NVMe" do
      command "[ -d /#{node["nvme"]["name"]} ] && [ ! -f #{nvme}/ibdata1 ] && mkdir -p #{nvme} && rsync -avh --ignore-errors #{bak}/ #{nvme}/ && service mysql restart"
      minute "*"
    end
  end

  query = "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '#{node["mysql"]["root_password"]}';"
  execute "set_root_password" do
    command "echo \"#{query}\" | mysql -uroot"
    only_if "echo 'show databases' | mysql -uroot mysql;"
    notifies :start, "service[mysql.service]", :before
  end

  # Create stripe db
  query = "CREATE DATABASE IF NOT EXISTS stripe;"

  execute "create_stripe_db" do
    command "echo \"#{query}\" | mysql -uroot -p#{node["mysql"]["root_password"]}"
    only_if "echo 'show databases' | mysql -uroot -p#{node["mysql"]["root_password"]} mysql;"
    notifies :start, "service[mysql.service]", :before
  end

  # Create jbx user
  query = <<-EOH
    UPDATE mysql.user SET Host='%' WHERE Host='localhost' AND User='root';
    CREATE USER IF NOT EXISTS jbx;
    FLUSH PRIVILEGES;
    GRANT ALL ON *.* TO 'root'@'%';
    GRANT ALL ON *.* TO 'jbx'@'%';
    FLUSH PRIVILEGES;
    SET GLOBAL event_scheduler=on;
    SET GLOBAL sql_mode='NO_ENGINE_SUBSTITUTION';
  EOH

  execute "manage_mysql_settings" do
    command "echo \"#{query}\" | mysql -uroot -p#{node["mysql"]["root_password"]}"
    only_if "echo 'show databases' | mysql -uroot -p#{node["mysql"]["root_password"]} mysql;"
    notifies :start, "service[mysql.service]", :before
  end

  edit_resource(:service, "mysql.service") do
    service_name "mysql"

    # If MySQL is installed on NVMe, delay restart to ensure files are restored first
    subscribes :restart, "template[/etc/mysql/my.cnf]", (File.directory?(bak) ? :delayed : :immediate)
    subscribes :restart, "execute[restore_mysql]", :immediate
    subscribes :restart, "replace_or_add[mysql.service]", :delayed unless node[:container]

    action node["configure"]["services"]["mysql"]
  end
else
  cron "Backup MySQL NVMe" do
    action :delete
  end

  cron "Restore MySQL NVMe" do
    action :delete
  end
end
