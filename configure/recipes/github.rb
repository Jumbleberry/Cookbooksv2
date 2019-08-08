#
user_home_dir = node["openresty"]["user_home"]

directory "#{user_home_dir}/.ssh" do
  owner node[:user]
  group node[:user]
  recursive true
end
cookbook_file "#{user_home_dir}/.ssh/config" do
  source "config"
  owner node[:user]
  group node[:user]
  mode "0600"
  action :create
end

if node.attribute?(:ec2)
  cookbook_file "#{user_home_dir}/.ssh/jumbleberry-github.tpl" do
    source "jumbleberry-github.tpl"
    mode "0600"
    only_if { (keys = Vault.logical.read("secret/data/#{node["environment"]}/keys")) && !keys.data[:data][:jumblebot].nil? }
    notifies :create, "consul_template_config[jumbleberry-github]", :immediately
    owner node[:user]
    group node[:user]
  end
  consul_template_config "jumbleberry-github" do
    templates [{
      source: "#{user_home_dir}/.ssh/jumbleberry-github.tpl",
      destination: "#{user_home_dir}/.ssh/jumbleberry-github",
      command: "chmod 600 #{user_home_dir}/.ssh/jumbleberry-github",
    }]
    action :nothing
    notifies :enable, "service[consul-template]", :immediate
    notifies :start, "service[consul-template]", :immediate
    notifies :reload, "service[consul-template]", :immediate
  end
end

ssh_known_hosts_entry "github" do
  host "github.com"
end
