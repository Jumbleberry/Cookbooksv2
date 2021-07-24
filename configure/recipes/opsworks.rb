ohai_plugin "opsworks" do
  path node["configure"]["plugin_path"]
  compile_time true
end
