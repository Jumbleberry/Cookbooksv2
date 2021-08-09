execute "ip route" do
  command <<-EOH
    defrt=$(ip route | grep "^default" | head -1 | sed -e 's/ initcwnd [0-9]\+//g' | sed -e 's/ initrwnd [0-9]\+//g')
    ip route change $defrt initcwnd #{node["base"]["initcwnd"]} initrwnd #{node["base"]["initrwnd"]}
  EOH
  not_if "ip route | grep '^default' | head -1 | grep -q 'initcwnd #{node["base"]["initcwnd"]} initrwnd #{node["base"]["initrwnd"]}'"
end
