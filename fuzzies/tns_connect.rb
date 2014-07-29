# Oracle TNS connect fuzzer, for firewall handler testing

request :tns_connect do
  size :connect, :name => :payload_length, :length => 2, :fuzzable => true, :endian => '>', :math => ->(x) { x + 8 }
  word 0x0000, :endian => '>', :name => :packet_chksum
  byte 0x01, :name => :type
  byte 0x00, :name => :reserved
  word 0x0000, :name => :header_chksum
  
  block :connect do
    word 0x0134, :name => :version, :endian => '>'
    word 0x012c, :name => :version_compat, :endian => '>'
    word 0x0000, :name => :service_opt, :endian => '>'
    word 0x0800, :name => :sdu, :endian => '>'
    word 0x7fff, :name => :mtu, :endian => '>'
    word 0x4f98, :name => :proto_char, :endian => '>'
    word 0x0000, :name => :line_turn_val, :endian => '>'
    word 0x0001, :name => :one_in_hw
    
    size :connect_data, :name => :connect_data_length, :length => 2, :fuzzable => true, :endian => '>'
    word 50,     :name => :connect_data_offset, :endian => '>'
    dword 0x0,   :name => :max_rx_conn_data, :endian => '>'
    word 0x0101, :name => :connect_flags, :endian => '>'
    dword 0x0,   :name => :trace_cross_1, :endian => '>'
    dword 0x0,   :name => :trace_cross_2, :endian => '>'
    qword 0x0,   :name => :trace_conn_id, :endian => '>'
    
    block :connect_data do
      # (DESCRIPTION=(CONNECT_DATA=(SID=smprd2)(CID=(PROGRAM=)(HOST=__jdbc__)(USER=)))(ADDRESS=(PROTOCOL=tcp)(HOST=scbe65002.central)(PORT=1521)))
      delim  '('
      string 'DESCRIPTION'
      delim  '='
      delim  '('
      string 'CONNECT_DATA'
      delim  '='
      delim  '('
      string 'SID'
      delim  '='
      string 'smprd2'
      delim  ')'
      delim  '('
      string 'CID'
      delim  '='
      delim  '('
      string 'PROGRAM'
      delim  '='
      string ''
      delim  ')'
      delim  '('
      string 'HOST'
      delim  '='
      string '__jdbc__'
      delim  ')'
      delim  '('
      string 'USER'
      delim  '='
      string ''
      delim  ')'
      delim  ')'
      delim  ')'
      delim  '('
      string 'ADDRESS'
      delim  '='
      delim  '('
      string 'PROTOCOL'
      delim  '='
      string 'TCP'
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
      string '100'
      delim  ')'
      delim  '('
      string 'PORT'
      delim  '='
      string '1521'
      delim  ')'
      delim  ')'
      delim  ')'
    end
  end
end

sess_opts = {
  :logfile          => 'tmp/tns.log',
  :logfile_level    => :error,
  :session_filename => 'tmp/tns.state',
  :crash_sleep_time => 5,
  :crash_threshold  => 50
}

session :tns, sess_opts do
  connect :tns_connect

  target(
    :transport => {
      :type         => :tcp,
      :host         => '172.16.8.100',
      :port         => 1521,
      :read_timeout => 0.01
  },
    :monitor   => {
      :type         => :fortigate,
      :telnet_host  => '172.16.8.100',
      :telnet_pass  => 'hacked'
  })

  fuzz
end
