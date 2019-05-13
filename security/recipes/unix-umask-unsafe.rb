# Change default umask: "077" for all Users

# 077 means that no one but the owner is able to read or execute newly-created files.

puts '  * Changed default umask: "077" for all Users'
file = Chef::Util::FileEdit.new("/etc/login.defs")
file.search_file_replace_line("^UMASK\t\t022", "UMASK\t\t077")
file.write_file
