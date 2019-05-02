# Disable ICMP redirection feature.

# There is a risk that this feature could be used to subvert a host's routing table
#  in order to compromise its security (e.g., tricking it into sending packets 
#  via a specific route where they may be sniffed or altered).

icmp_redirect = ['net.ipv4.conf.all.accept_redirects'    , \
                 'net.ipv4.conf.default.accept_redirects', \
                 'net.ipv4.conf.all.secure_redirects'    , \
                 'net.ipv4.conf.default.secure_redirects' ]

icmp_redirect.each do |params| 
  sysctl params do 
    value 0 
  end
end
