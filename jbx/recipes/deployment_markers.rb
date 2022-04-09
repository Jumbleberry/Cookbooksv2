require 'json'
require 'net/http'
require 'uri'

commit_hash = %x(cd #{node["jbx"]["path"]}; git rev-parse HEAD)

ruby_block "sleuth_deployment" do
    block do
        file = File.read('/var/www/jbx/config/credentials.json')
        data_hash = JSON.parse(file)
        
        uri = URI.parse("https://app.sleuth.io/api/1/deployments/galactic-propeller/jbx/register_deploy")
        request = Net::HTTP::Post.new(uri)
        request.set_form_data(
        "api_key" => "#{data_hash['sleuth']['key']}",
        "environment" => "#{data_hash['sleuth']['env']}",
        "sha" => "#{commit_hash}",
        )

        req_options = {
        use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
        end
        
    end
    action :run
end
