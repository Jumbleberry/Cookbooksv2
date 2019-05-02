# Changing permission mode for: user's home directory 

# 0700 - means that no one but the owner is able to read or execute newly-created files.

Dir.open('/home').each do |user|
  next if user.start_with?('.')
  directory "/home/#{user}" do
    mode '0700'
    action :create
    recursive false
    only_if do Dir.exist?("/home/#{user}") end
  end
end
