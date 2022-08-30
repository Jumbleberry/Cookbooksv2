node[cookbook_name]["kernel"] || {}.each_pair do |property, value|
  sysctl_param "kernel.#{property}" do
    value value
  end
end

node[cookbook_name]["net"] || {}.each_pair do |property, value|
  sysctl_param "net.#{property}" do
    value value
  end
end

node[cookbook_name]["vm"] || {}.each_pair do |property, value|
  sysctl_param "vm.#{property}" do
    value value
  end
end

# Disable transparent huge pages
execute "disable-thp" do
  command "echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled"
  not_if "cat /sys/kernel/mm/transparent_hugepage/enabled | grep  '\[madvise\]'"
end
