# Use kvm clocksource if possible
execute "kvm-clock" do
  command "echo kvm-clock > /sys/devices/system/clocksource/clocksource0/current_clocksource"
  only_if "cat /sys/devices/system/clocksource/clocksource0/available_clocksource | grep -q kvm-clock"
end
