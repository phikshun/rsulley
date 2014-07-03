request :radacct, :encoder => ->(x) { x[4..19] = Digest::MD5.digest(x + "password"); x } do
  static "\x04"
  calc -> { rand(256).chr }
  size :body, :length => 2, :endian => '>', :math => ->(x) { x + 4 }

  block :body do
    static "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
  
    static "\x01"
    size :user, :length => 1, :math => ->(x) { x + 2 }
    block :user do
      string "FORTINET", :max_len => 255
      delim "\\"
      string "devin", :max_len => 255
    end
  
    static "\x28"
    size :acct_status_type, :length => 1, :math => ->(x) { x + 2 }
    block :acct_status_type do
      dword 1, :endian => '>'
    end

    static "\x2c"
    size :acct_session_id, :length => 1, :math => ->(x) { x + 2 }
    block :acct_session_id do
      string "390", :max_len => 255
    end
  
    static "\x1f"
    size :calling_station_id, :length => 1, :math => ->(x) { x + 2 }
    block :calling_station_id do
      string "192", :max_len => 255
      delim "."
      string "168", :max_len => 255
      delim "."
      string "1", :max_len => 255
      delim "."
      string "1", :max_len => 255
    end
  
    static "\x19"
    size :class, :length => 1, :math => ->(x) { x + 2 }
    block :class do
      string "DOMAIN USERS", :max_len => 255
    end
  end
end

session :radius, :logfile => 'tmp/radacct.log', :logfile_level => :error, :session_filename => 'tmp/radacct.state'

session :radius do
  connect :radacct
end

session :radius do
  target(
    :transport => {
        :type         => :udp,
        :host         => '172.16.8.100',
        :port         => 1813,
        :read_timeout => 1
      }
  )
end

session :radius do
  fuzz
end
