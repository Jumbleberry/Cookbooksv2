# Make sure directory exists
directory "/usr/share/php/zf1" do
  owner node["user"]
  group node["user"]
  recursive true
end

# Checkout ZF1
git "/usr/share/php/zf1" do
  repository "https://github.com/zendframework/zf1.git"
  reference "master"
  user node["user"]
  action :sync
end
