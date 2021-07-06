# Security fixes
case node["platform"]
# tested on Ubuntu 16.04.6 / 18.04.2, Centos7.6.1810 , ec2 amzn.2 (20190504.0.0)
when "ubuntu", "amazon", "centos"
  include_recipe "security::linux-icmp-redirect"
  #   include_recipe 'security::unix-umask-unsafe'
  include_recipe "security::generic-tcp-timestamp"
  include_recipe "security::unix-anonymous-root-ssh-logins"
  include_recipe "security::unix-user-home-dir-mode"

  # tty removed in >= 20
  if node["lsb"]["release"].to_i < 20
    include_recipe "security::unix-anonymous-root-tty-logins"
  end
else
  print " !!!! -> #{node["platform"]} <- this OS not tested yet "
end
