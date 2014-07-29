# Oracle TNS redirect fuzzer, for firewall handler testing

request :tns_redirect do
  size :redirect, :name => :payload_length, :length => 2, :fuzzable => true, :endian => '>', :math => ->(x) { x + 8 }
  word 0x0000, :endian => '>', :name => :packet_chksum
  byte 0x05, :name => :type
  byte 0x00, :name => :reserved
  word 0x0000, :name => :header_chksum
  
  block :redirect do
    size :redirect_data, :name => :redirect_data_length, :length => 2, :fuzzable => true, :endian => '>'
    
    block :redirect_data do
      # (ADDRESS=(PROTOCOL=tcp)(HOST=192.168.239.2)(PORT=2123))
      delim  '('
      string 'ADDRESS'
      delim  '='
      delim  '('
      string 'PROTOCOL'
      delim  '='
      string 'tcp'
      delim  ')'
      delim  '('
      string 'HOST'
      delim  '='
      string '172'
      delim  '.'
      string '16'
      delim  '.'
      string '8'
      delim  '.'
      string '1'
      delim  ')'
      delim  '('
      string 'PORT'
      delim  '='
      calc   ->() { rand(5).times.map { (rand(10) + 48).chr }.join('') }
      delim  ')'
      delim  ')'
    end
  end
end

sess_opts = {
  :logfile          => 'tmp/tns.log',
  :logfile_level    => :error,
  :session_filename => 'tmp/tns.state',
  :crash_threshold  => 50,
  :server_mode      => true
}

session :tns, sess_opts do
  connect :tns_redirect

  target(
    :transport => {
      :type         => :tcp_server,
      :host         => '172.16.8.100',
      :port         => 1521,
      :read_timeout => 0.1
  },
    :monitor   => {
      :type         => :fortigate,
      :telnet_host  => '172.16.8.100',
      :telnet_pass  => 'hacked'
  })

  fuzz
end
