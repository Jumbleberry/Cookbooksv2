unless node.attribute?(:ec2)
  edit_resource(:service, "mysql.service") do
    subscribes :restart, "cookbook_file[/etc/mysql/my.cnf]", :immediately
  end

  # Copy config file
  cookbook_file "/etc/mysql/my.cnf" do
    source "my.cnf"
    owner "root"
    group "root"
    mode "0644"
  end

  query = "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY \'#{node["mysql"]["root_password"]}\'; FLUSH PRIVILEGES;"
  execute "set_root-password" do
    command "echo \"#{query}\" | mysql -uroot"
    only_if "echo 'show databases' | mysql -uroot mysql;"
  end

  # Create jbx user
  query = "GRANT ALL ON *.* TO \'jbx\'@\'%\' IDENTIFIED BY \'#{node["mysql"]["root_password"]}\'"
  execute "create_jbx_user" do
    command "echo \"#{query}\" | mysql -uroot -p#{node["mysql"]["root_password"]}"
    only_if "echo 'show databases'  | mysql -uroot -p#{node["mysql"]["root_password"]} mysql;"
  end

  # Create 'root'@'%'
  query = "GRANT ALL ON *.* TO \'root\'@\'%\' IDENTIFIED BY \'#{node["mysql"]["root_password"]}\'"
  execute "create_root_user" do
    command "echo \"#{query}\" | mysql -uroot -p#{node["mysql"]["root_password"]}"
    only_if "echo 'show databases'  | mysql -uroot -p#{node["mysql"]["root_password"]} mysql;"
  end
end