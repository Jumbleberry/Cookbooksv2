unless node.attribute?(:ec2)
  replace_or_add "sshd_config_root_login" do
    path "/etc/ssh/sshd_config"
    pattern "PermitRootLogin.*"
    line "PermitRootLogin yes"
    notifies :restart, "service[sshd.service]"
  end

  replace_or_add "sshd_config_password_login" do
    path "/etc/ssh/sshd_config"
    pattern "PasswordAuthentication.*"
    line "PasswordAuthentication yes"
    notifies :restart, "service[sshd.service]"
  end

  edit_resource(:service, "sshd.service") do
    service_name "sshd"
    supports status: true, restart: true, reload: true
    action node["configure"]["services"]["sshd"] || %i{stop disable}
  end
end
