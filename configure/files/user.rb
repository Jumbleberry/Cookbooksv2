Ohai.plugin(:User) do
  provides "user"
  depends "user"
  depends "etc/passwd"

  collect_data(:default) do
    if (etc["passwd"].key?("vagrant"))
      user("www-data")
    elsif (etc["passwd"].key?("ubuntu"))
      user("www-data")
    else
      user("root")
    end
  end
end
