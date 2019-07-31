directory "#{node["etc"]["passwd"][node[:user]]["dir"]}/.ssh" do
  owner node[:user]
  group node[:user]
  recursive true
end
cookbook_file "#{node["etc"]["passwd"][node[:user]]["dir"]}/.ssh/config" do
  source "config"
  owner node[:user]
  group node[:user]
  mode "0600"
  action :create
end

if node.attribute?(:ec2)
  cookbook_file "#{node["etc"]["passwd"][node[:user]]["dir"]}/.ssh/jumbleberry-github.tpl" do
    source "jumbleberry-github.tpl"
    mode "0644"
    notifies :create, "consul_template_config[jumbleberry-github]", :immediately
    owner node[:user]
    group node[:user]
  end
  consul_template_config "jumbleberry-github" do
    templates [{
      source: "#{node["etc"]["passwd"][node[:user]]["dir"]}/.ssh/jumbleberry-github.tpl",
      destination: "#{node["etc"]["passwd"][node[:user]]["dir"]}/.ssh/jumbleberry-github",
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
