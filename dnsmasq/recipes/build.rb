execute "download dnsmasq" do
  command <<-EOH
      apt-get update \
        && apt-get install -yq gettext libdbus-1-dev libidn11-dev libnetfilter-conntrack-dev nettle-dev \
        && wget -q https://thekelleys.org.uk/dnsmasq/dnsmasq-#{node["dnsmasq"]["version"]}.tar.gz -O dnsmasq-#{node["dnsmasq"]["version"]}.tar.gz \
        && tar -xzf dnsmasq-#{node["dnsmasq"]["version"]}.tar.gz
    EOH
  cwd "/tmp"
end

# manually edit src/config.h
# Uncomment "/* #define HAVE_(DBUS|IDN|CONNTRACK|DNSSEC) */" to:
#   #define HAVE_DBUS
#   #define HAVE_IDN
#   #define HAVE_CONNTRACK
#   #define HAVE_DNSSEC

execute "make dnsmasq" do
  command "make clean && make all-i18n"
  cwd "/tmp/dnsmasq-#{node["dnsmasq"]["version"]}"
end
