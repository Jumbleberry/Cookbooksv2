ohai_plugin "user" do
  path node["configure"]["plugin_path"]
  compile_time true
end

unless node.attribute?(:ec2)
  user "root" do
    password "$1$glq2Di3b$.FKZCViTL.4q3GzPQk2ux/"
    action :modify
  end
end
