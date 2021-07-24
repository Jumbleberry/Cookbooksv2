Ohai.plugin(:Opsworks) do
  provides "opsworks"
  depends "etc/passwd"

  def flatten(obj, first = false, key = nil)
    if key == nil
      results = []
      obj.first.each do |o|
        results << o.raw_data
      end
    else
      results = {}
      obj.first.each do |o|
        results[o.raw_data[key]] = o.raw_data
      end
    end
    return first ? results.first : results
  end

  collect_data(:default) do
    if etc["passwd"]["aws"] && etc["passwd"]["aws"]["dir"].include?("opsworks")
      opsworks({
        "stack" => flatten(Chef::Search::Query.new.search("aws_opsworks_stack"), true),
        "layers" => flatten(Chef::Search::Query.new.search("aws_opsworks_layer"), false, "name"),
        "instance" => flatten(Chef::Search::Query.new.search("aws_opsworks_instance", "self:true"), true),
        "applications" => flatten(Chef::Search::Query.new.search("aws_opsworks_app")),
      })
    end
  end
end
