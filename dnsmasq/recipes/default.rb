package "dnsmasq"
user "dnsmasq"

if platform?("ubuntu") && node["lsb"]["release"].to_i >= 18
  if !node.attribute?(:container)
    directory "/etc/systemd/resolved.conf.d"

    file "Fix systemd-resolved conflict" do
      path "/etc/systemd/resolved.conf.d/dnsmasq.conf"
      content node["platform_version"].to_i >= 20 ? "[Resolve]\nDNSStubListener=no" : "[Resolve]\nDNS=127.0.0.1"
      notifies :restart, "service[systemd-resolved]", :immediately
    end

    # Fix symlink on resolve.conf
    # https://askubuntu.com/a/1001295
    link "/etc/resolv.conf" do
      to "/run/systemd/resolve/resolv.conf"
      action :create
      only_if { node["lsb"]["release"].to_i < 20 }
      notifies :restart, "service[systemd-resolved]", :immediately
    end

    service "systemd-resolved" do
      action :nothing
    end
  else
    service "systemd-resolved" do
      action [:stop, :disable]
    end
  end
end

include_recipe "dnsmasq::dns" if node["dnsmasq"]["enable_dns"]
include_recipe "dnsmasq::dhcp" if node["dnsmasq"]["enable_dhcp"]

service "dnsmasq" do
  action [:enable, :start]
end
