node["configure"]["services"].each do |service, status|
  node.override["configure"]["services"] = %i{stop disable}
end if node["configure"]["services"]
