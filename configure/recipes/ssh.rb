if !node.attribute?(:ec2)
  replace_or_add "sshd_config" do
    path "/etc/ssh/sshd_config"
    pattern "PermitRootLogin*"
    line "PermitRootLogin yes"
    notifies :restart, "service[sshd.service]"
  end
end
