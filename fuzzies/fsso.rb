# coding: binary

request :tsagent do
  size :main, :length => 2, :signed => true, :fuzzable => true, :endian => '>', :math => ->(x) { x + 2 }
  
  block :main do
    dword Time.now.to_i, :endian => '>'
    dword 3232296754, :endian => '>'
    
    size :logon, :length => 2, :signed => true, :fuzzable => true, :endian => '>'
    
    block :logon do
      string "192.168.239.50"
      delim "/"
      string "FORTINET"
      delim "/"
      string "administrator"
    end

    string "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
    dword  2, :endian => '>'
    word   0x8000, :endian => '>'
    
    word 0x0014, :endian => '>'
    dword 1, :endian => '>'
    dword 1, :endian => '>'
    string "\x13\x89"
    string "\x14\x50"
  end
end

session :dcagent, :logfile => 'tmp/dcagent.log', :logfile_level => :error, :session_filename => 'tmp/dcagent.state'

session :dcagent do
  connect :tsagent
end

session :dcagent do
  target(
    :transport => {
        :type         => :udp,
        :host         => '192.168.239.100',
        :port         => 8002,
        :read_timeout => 1
      }
  )
end

session :dcagent do
  fuzz
end
