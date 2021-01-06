if node["environment"] == "dev" && (node["configure"]["services"]["mysql"] && (node["configure"]["services"]["mysql"].include? "start"))
  edit_resource(:service, "mysql.service") do
    subscribes :restart, "cookbook_file[/etc/mysql/my.cnf]", :immediately
  end

  if node.attribute?(:nvme) && !FileTest.directory?("/#{node["nvme"]["name"]}/mysql")
    service "mysql" do
      action :stop
    end

    execute "backup_mysql" do
      command "mv /var/lib/mysql /var/lib/mysql.bak"
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
      command <<-EOH
        rsync -av /var/lib/mysql.bak/ /var/lib/mysql/
        sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
        sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld
      EOH
      user "root"
    end

    service "mysql" do
      action node["configure"]["services"]["mysql"]
    end
  end

  # Copy config file
  cookbook_file "/etc/mysql/my.cnf" do
    manage_symlink_source true
    source "my.cnf"
    owner "root"
    group "root"
    mode "0644"
  end

  query = "SET PASSWORD FOR 'root'@'localhost' = PASSWORD(\'#{node["mysql"]["root_password"]}\');"
  execute "set_root-password" do
    command "echo \"#{query}\" | mysql -uroot"
    only_if "echo 'show databases' | mysql -uroot mysql;"
  end

  # Set Global innodb settings via cli to address DEV-488
  query = "set global innodb_large_prefix=on; set global innodb_file_format=Barracuda;"
  execute "set_innodb" do
    command "echo \"#{query}\" | mysql -uroot -p#{node["mysql"]["root_password"]}"
  end

  # Create jbx user
  query = <<-EOH
    GRANT ALL ON *.* TO 'jbx'@'%' IDENTIFIED BY '#{node["mysql"]["root_password"]}'; \
    GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '#{node["mysql"]["root_password"]}'; \
    DELETE FROM mysql.user WHERE user = 'root' AND password = ''; \
    FLUSH PRIVILEGES;
  EOH

  execute "manage_mysql_users" do
    command "echo \"#{query}\" | mysql -uroot -p#{node["mysql"]["root_password"]}"
    only_if "echo 'show databases' | mysql -uroot -p#{node["mysql"]["root_password"]} mysql;"
  end
end
