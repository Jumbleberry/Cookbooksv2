execute "curl -s #{node["phalcon"]["install_script"]} | sudo bash"

apt_package "php#{node["php"]["version"]}-phalcon" do
  version node["phalcon"]["version"]
  action %i{install lock}
end

execute "apt-mark hold php#{node["php"]["version"]}-phalcon"

unless node.attribute?(:ec2)
  git "phalcon-devtools" do
    repository node["phalcon"]["devtools"]
    user "root"
    branch "v3.4.11"
    destination "/usr/share/phalcon-devtools"
    action :sync
  end

  bash "phalcon-devtools" do
    user "root"
    cwd "/usr/share/phalcon-devtools"
    code <<-EOH
              ./phalcon.sh
    EOH
    not_if do
      ::File.exist?("/usr/bin/phalcon")
    end
    notifies :create, "link[/usr/bin/phalcon]", :immediately
  end

  link "/usr/bin/phalcon" do
    to "/usr/share/phalcon-devtools/phalcon"
    action :nothing
  end
end
