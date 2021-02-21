if node[:configure][:update]
  execute "apt-get update" do
    action :run
  end
end

if node[:configure][:upgrade]
  execute "DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq" do
    action :run
  end
end
