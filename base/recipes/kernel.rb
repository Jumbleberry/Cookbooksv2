
node[cookbook_name]['kernel'].each_pair do |property, value|
    sysctl_param "kernel.#{property}" do
        value value
    end
end