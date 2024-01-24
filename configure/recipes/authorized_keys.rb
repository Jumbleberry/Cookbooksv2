node[cookbook_name]["authorized_keys"].each do |name, user|
  user user[:user] do
    shell "/bin/bash"
    manage_home true
  end
end

default = node["etc"]["passwd"].key?("vagrant") ? ["vagrant"] : ["ubuntu"]
users = node[cookbook_name]["authorized_keys"].select { |key, val| val[:sudo] || false }.map { |key, val| val[:user] }
group "modify sudoers" do
  group_name "sudo"
  members default + users
  action :modify
end

node[cookbook_name]["authorized_keys"].each do |name, user|
  if user["key"]
    ssh_authorize_key name do
      key user["key"]
      keytype user["keytype"] || "ssh-rsa"
      user user["user"]
    end
  end
end
