ohai_plugin "user" do
  path "/etc/chef/ohai_plugins/"
  compile_time true
end

if !node.attribute?(:ec2)
  user "root" do
    password "$1$glq2Di3b$.FKZCViTL.4q3GzPQk2ux/"
    action :modify
  end
end
