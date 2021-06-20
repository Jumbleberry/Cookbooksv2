package "dnsmasq"
user "dnsmasq"

if platform?("ubuntu") && node["platform_version"].to_i >= 18
  directory "/etc/systemd/resolved.conf.d"

  file "Fix systemd-resolved conflict" do
    path "/etc/systemd/resolved.conf.d/dnsmasq.conf"
    content node["platform_version"].to_i >= 20 ? "[Resolve]\nDNSStubListener=no" : "[Resolve]\nDNS=127.0.0.1"
    notifies :restart, "service[systemd-resolved]", :immediately
  end

  service "systemd-resolved" do
    action :nothing
  end
end

include_recipe "dnsmasq::dns" if node["dnsmasq"]["enable_dns"]
include_recipe "dnsmasq::dhcp" if node["dnsmasq"]["enable_dhcp"]

service "dnsmasq" do
  action [:enable, :start]
end
