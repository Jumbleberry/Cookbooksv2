if node["environment"] == "dev" && (node["configure"]["services"]["mysql"] && (node["configure"]["services"]["mysql"].include? "start"))
  # Fixes poor IO performance on dev/ci when seeding tables
  execute "echo noop > /sys/block/sda/queue/scheduler" do
    only_if { node["lsb"]["release"].to_i < 20 }
    ignore_failure true
  end

  # Copy config file
  cookbook_file "/etc/mysql/my.cnf" do
    manage_symlink_source true
    source "my.cnf"
    owner "root"
    group "root"
    mode "0644"
  end

  if node.attribute?(:nvme) && !FileTest.directory?("/#{node["nvme"]["name"]}/mysql")
    service "mysql" do
      action :stop
    end

    execute "backup_mysql" do
      command <<-EOH
        mv /var/lib/mysql /var/lib/mysql.bak
        sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
        sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld
      EOH
      user "root"
      not_if { ::File.directory?("/var/lib/mysql.bak") }
    end

    directory "/#{node["nvme"]["name"]}/mysql" do
      recursive true
      owner "mysql"
      group "mysql"
      mode "0755"
      action :create
    end

    link "/var/lib/mysql" do
      to "/#{node["nvme"]["name"]}/mysql"
      owner "mysql"
      group "mysql"
      action :create
    end

    # Restore mysql & disable apparmor as it wont allow reads from /nvme* and this instance is dev only
    execute "restore_mysql" do
      command "rsync -av /var/lib/mysql.bak/ /var/lib/mysql/"
      user "root"
    end
  end

  query = "SET PASSWORD FOR 'root'@'localhost' = PASSWORD(\'#{node["mysql"]["root_password"]}\');"
  execute "set_root_password" do
    command "echo \"#{query}\" | mysql -uroot"
    only_if "echo 'show databases' | mysql -uroot mysql;"
    action :nothing
  end

  # Create jbx user
  query = <<-EOH
    GRANT ALL ON *.* TO 'jbx'@'%' IDENTIFIED BY '#{node["mysql"]["root_password"]}'; \
    GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '#{node["mysql"]["root_password"]}'; \
    DELETE FROM mysql.user WHERE user = 'root' AND password = ''; \
    FLUSH PRIVILEGES;
    SET GLOBAL innodb_large_prefix=on;
    SET GLOBAL innodb_file_format=Barracuda;
    SET GLOBAL event_scheduler=on;
    SET GLOBAL sql_mode='NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
  EOH

  execute "manage_mysql_settings" do
    command "echo \"#{query}\" | mysql -uroot -p#{node["mysql"]["root_password"]}"
    only_if "echo 'show databases' | mysql -uroot -p#{node["mysql"]["root_password"]} mysql;"
  end

  edit_resource(:service, "mysql.service") do
    # If MySQL is installed on NVMe, delay restart to ensure files are restored first
    subscribes :restart, "cookbook_file[/etc/mysql/my.cnf]", File.directory?("/var/lib/mysql.bak") ? :delayed : :immediate
    subscribes :restart, "execute[restore_mysql]", :immediate

    notifies :run, "execute[set_root_password]", :immediate
    notifies :run, "execute[manage_mysql_settings]", :immediate
  end
end
