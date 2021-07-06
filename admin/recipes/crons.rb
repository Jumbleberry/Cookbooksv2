if node["admin"].key?("crons")
  node["admin"]["crons"].each do |definition|
    cron definition[:name] || definition[:command] do
      command definition[:command]
      month definition[:month] || "*"
      weekday definition[:weekday] || "*"
      hour definition[:hour] || "*"
      minute definition[:minute] || "0"
      user node[:user]
      action definition[:action] || :create
    end
  end
end
