# Disabling root login through ssh

# To prevent users or attackers from logging in directly as root, user has to "su" to become root.

puts "  * Disabled root login through ssh"
file = Chef::Util::FileEdit.new("/etc/ssh/sshd_config")
file.search_file_replace_line(/^#?\s?PermitRootLogin/,'PermitRootLogin no' )
file.search_file_replace_line(/^PermitRootLogin yes/,'PermitRootLogin no' )
file.write_file

service "sshd" do
  action :restart
end
