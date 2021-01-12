if node[:configure][:update]
  execute "apt-get update" do
    action :run
  end
end

if node[:configure][:upgrade]
  execute "apt-get upgrade -y" do
    action :run
  end
end
