# Disable TCP timestamp responses 
 
# The remote host responded with a TCP timestamp.
# The TCP timestamp response can be used to approximate the remote host's uptime, potentially aiding in further attacks.
# Additionally, some operating systems can be fingerprinted based on the behavior of their TCP timestamps.

sysctl 'net.ipv4.tcp_timestamps' do
  value 0 
end
