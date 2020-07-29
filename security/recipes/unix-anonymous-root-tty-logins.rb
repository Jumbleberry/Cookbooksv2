# Removing Anonymous root logins except console - tty[0-9]

# Preventing Access to Single User Mode
# — If attackers can boot the system into single user mode,
# they are logged in automatically as root without being prompted for the root password.

puts "  * Removed Anonymous root logins (except console - tty[0-9])"
file = Chef::Util::FileEdit.new("/etc/securetty")
file.search_file_replace(/^#?\s?(.+)$/, '# \1')
file.search_file_replace(/^#?\s?(tty[0-9])$/, '\1')
file.write_file
