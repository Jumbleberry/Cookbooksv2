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
  template "#{user_home_dir}/.ssh/jumbleberry-github.tpl" do
    source "jumbleberry-github.tpl.erb"
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
    notifies :reload, "service[consul-template.service]", :immediate
    notifies :run, "ruby_block[wait for jumbleberry-github]", :immediate
  end
  ruby_block "wait for jumbleberry-github" do
    block do
      iter = 0
      until ::File.exist?("#{node["openresty"]["user_home"]}/.ssh/jumbleberry-github") || iter > 15
        sleep 1
        iter += 1
      end
    end
    action :nothing
  end
end

ssh_known_hosts_entry "github" do
  host "github.com"
end
