Ohai.plugin(:IpAddress) do
    provides 'ipaddress'
    depends 'ipaddress', 'network/interfaces'
    depends 'virtualization/system', 'etc/passwd'
    
    collect_data(:default) do
        if virtualization['system'] == 'vbox'
            if etc['passwd'].any? { |k, v| k == 'vagrant' }
                for interface in ['eth1', 'enp0s8']
                    if network['interfaces'][interface]
                        ipaddress(network['interfaces'][interface]['addresses'].detect{|k,v| v[:family] == 'inet'}.first)
                    end
                end
            end
        end
    end
end