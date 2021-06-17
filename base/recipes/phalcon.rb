execute "curl -s #{node["phalcon"]["install_script"]} | sudo bash"
phalcon_package = node["lsb"]["release"].to_i < 20 ? "php#{node["php"]["version"]}-phalcon" : "php#{node["php"]["version"]}-phalcon3"

apt_package "#{phalcon_package}" do
  version node["phalcon"]["version"]
  action %i{install lock}
end

execute "apt-mark hold #{phalcon_package}"

unless node.attribute?(:ec2)
  git "phalcon-devtools" do
    repository node["phalcon"]["devtools"]
    user "root"
    branch "3.4.x"
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
