Ohai.plugin(:IpAddress) do
  provides "ipaddress"
  depends "ec2"
  depends "ipaddress", "network/interfaces"
  depends "virtualization/system", "etc/passwd"

  collect_data(:default) do
    unless ec2
      if virtualization["system"] == "vbox" || virtualization["system"] == "docker"
        %w{eth0 eth1 enp0s8}.each do |interface|
          if network["interfaces"][interface]
            ipaddress(network["interfaces"][interface]["addresses"].detect { |k, v| v[:family] == "inet" }.first)
          end
        end
      end
    end
  end
end
