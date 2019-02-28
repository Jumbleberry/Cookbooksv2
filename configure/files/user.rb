Ohai.plugin(:User) do
  provides "user"
  depends "user"
  depends "etc/passwd"

  collect_data(:default) do
    if (etc["passwd"].key?("vagrant"))
      user("vagrant")
    elsif (etc["passwd"].key?("ubuntu"))
      user("ubuntu")
    else
      user("root")
    end
  end
end
