execute "curl -s #{node["phalcon"]["install_script"]} | sudo bash"

package "php#{node["php"]["version"]}-phalcon" do
  action :install
  version node["phalcon"]["version"]
end

if !node.attribute?(:ec2)
  git "phalcon-devtools" do
    repository node["phalcon"]["devtools"]
    user "root"
    branch "master"
    destination "/usr/share/phalcon-devtools"
    action :sync
  end

  bash "phalcon-devtools" do
    user "root"
    cwd "/usr/share/phalcon-devtools"
    code <<-EOH
              ./phalcon.sh
              ln -s /usr/share/phalcon-devtools/phalcon.php /usr/bin/phalcon
          EOH
    not_if do
      ::File.exists?("/usr/bin/phalcon")
    end
  end
end
