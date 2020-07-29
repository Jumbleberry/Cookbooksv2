# Changing permission mode for: user's home directory

# 0700 - means that no one but the owner is able to read or execute newly-created files.

Dir.open("/home").each do |user|
  next if user.start_with?(".")

  uid = "#{node["etc"]["passwd"]["#{user}"]["uid"]}".to_i
  if  999 < uid && uid < 60001
    directory "/home/#{user}" do
      mode "0700"
      action :create
      recursive false
    end
  end
end
