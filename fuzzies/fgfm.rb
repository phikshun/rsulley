request :auth_reply do
  word 0x36e0, name: 'magic', endian: '<'
  byte 0x11, name: 'ver'
  byte 0x00, name: 'type'
  size :data, length: 4, signed: false, fuzzable: true, endian: '>', math: ->(x) { x + 8 }
  
  block :data do
    # reply 200\r\nrequest=auth\r\nserialno=FMG-VM0A12000459\r\nuser=admin\r\npasswd=test\r\nkeepalive_interval=120\r\nchan_window_sz=32768\r\nsock_timeout=360\r\n\r\n\x00
    string "reply"
    delim  " "
    string "200"
    delim  "\r\n"
    string "request"
    delim  "="
    string "auth"
    delim  "\r\n"
    string "serialno"
    delim  "="
    string "FMG-VM0A12000459"
    delim  "\r\n"
    string "user"
    delim  "="
    string "admin"
    delim  "\r\n"
    string "passwd"
    delim  "="
    string "test"
    delim  "\r\n"
    string "keepalive_interval"
    delim  "="
    string "120"
    delim  "\r\n"
    string "chan_window_sz"
    delim  "="
    string "32768"
    delim  "\r\n"
    string "sock_timeout"
    delim  "="
    string "360"
    delim  "\r\n"
    delim  "\r\n"
    string "\x00"
  end
end

sess_opts = {
  logfile:          'tmp/fgfm.log',
  logfile_level:    :error,
  session_filename: 'tmp/fgfm.state',
  crash_sleep_time: 5,
  sleep_time:       1
}

session :fgfm, sess_opts do
  connect :auth_reply

  target(
    transport: {
      type:             :ssl,
      ssl_server_mode:  true,
      ssl_cert:         'fmg.cer',
      ssl_key:          'fmg.key',
      ssl_ca:           'fgt.pem',
      host:             '172.16.8.101',
      port:             541,
      read_timeout:     0.1
    },
    monitor: {
      type:             :fortigate,
      telnet_host:      '172.16.8.101',
      extra_cmds:       'sysctl killall fgfm'
    }
  )

  fuzz
end
