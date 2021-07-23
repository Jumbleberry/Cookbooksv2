node["configure"]["elb"]["target_groups"].each do |target|
  execute "add_to_elb #{target}" do
    command <<-EOH
      aws elbv2 register-targets \
          --target-group-arn #{target} \
          --targets Id=#{node["ec2"]["instance_id"]} \
          --region #{node["ec2"]["placement_availability_zone"].sub!(/[a-zA-Z]*?$/, "")}
    EOH
    only_if { node.attribute?(:ec2) && node["ec2"]["instance_id"] }
  end
end
