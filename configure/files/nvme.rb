Ohai.plugin(:NVMe) do
  provides "nvme"
  depends "ec2"
  depends "filesystem2/by_device/mounts"

  collect_data(:default) do
    if ec2
      filesystem2[:by_device].each do |path, device|
        if path =~ /nvme[1-9][a-z][1-9]$/ && !filesystem2[:by_device].keys.any? { |d| d != path && d.include?(path) } && !(device[:mounts] || []).any? { |m| m == "/" }
          return nvme(device.merge!({ :name => File.basename(path), :path => path }))
        end
      end
    end
  end
end
