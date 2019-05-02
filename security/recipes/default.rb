# Security fixes 
case node['platform']
when 'ubuntu'
  include_recipe 'security::linux-icmp-redirect'
  include_recipe 'security::unix-umask-unsafe'
  include_recipe 'security::generic-tcp-timestamp'
  include_recipe 'security::unix-anonymous-root-tty-logins'
  include_recipe 'security::unix-anonymous-root-ssh-logins'
  include_recipe 'security::unix-user-home-dir-mode'
else
   print " !!!! -> #{node['platform']} <- this OS not tested yet "
end
