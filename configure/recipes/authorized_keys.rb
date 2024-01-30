node[cookbook_name]["authorized_keys"].each do |name, user|
  user user[:user] do
    shell "/bin/bash"
    manage_home true
  end
end

include_recipe "sudo"

node[cookbook_name]["authorized_keys"].each do |name, user|
  if user["key"]
    ssh_authorize_key name do
      key user["key"]
      keytype user["keytype"] || "ssh-rsa"
      user user["user"]
    end
  end
end
