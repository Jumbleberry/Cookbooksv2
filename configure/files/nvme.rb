Ohai.plugin(:NVMe) do
  provides "nvme"
  depends "ec2"
  depends "filesystem2/by_device/mounts"

  collect_data(:default) do
    if ec2
      filesystem2[:by_device].each do |name, device|
        if name =~ /nvme[1-9][a-z][1-9]$/ && !filesystem2[:by_device].keys.any? { |d| d != name && d.include?(name) } && !(device[:mounts] || []).any? { |m| m == "/" }
          return nvme(device.merge!({ :name => name }))
        end
      end
    end
  end
end
