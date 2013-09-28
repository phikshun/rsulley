# ftp fuzzer borrowed from http://code.google.com/p/ftpfuzz

request :datauser do
  static "USER anon\r\n"
end

request :datapass do
  static "PASS anon\r\n"
end

request :dataport do
  static "PORT 127, 0, 0, 1, 4, 1\r\n"
end

request :datapasv do
  static "PASV\r\n"
end

request :datarest do
  static "REST 9999\r\n"
end

request :datarnfr do
  static "RNFT test\r\n"
end

request :dataquit do
  static "QUIT\r\n"
end

request :auser do
  static "USER"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :apass do
  static "PASS"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :ahelp do
  static "HELP"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :aacct do
  static "ACCT"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :ahost do
  static "HOST"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :aauth do
  static "AUTH"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :aadat do
  static "ADAT"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :apbsz do
  static "PBSZ"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :aprot do
  static "PROT"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :dataset1 do
  group  :commands1, "HELP", "ACCT", "CWD", "SMNT", "RETR", "STOR", "STOU", "APPE", "REST", "RNFR", "RNTO", 
                     "DELE", "RMD", "MKD", "SITE", "HOST", "AUTH", "ADAT", "ALGS", "OPTS", "MDTM", "SIZE", 
                     "XRMD", "XMKD", "XCWD", "STRU", "MODE", "PROT", "STAT", "NLST", "LIST", "MLST", "MLSD", 
                     "CDUP", "REIN", "PASV", "ABOR", "SYST", "NOOP", "CCC", "LPSV", "XPWD", "PWD", "XCUP", "QUIT"
  block :datablock1, :group => :commands1 do
    delim  " "
    string "fuzz"
    static "\r\n"
  end
end

request :dataset2 do
  group :commands2, "MIC", "CONF", "ENC"
  block :datablock2, :group => :commands2 do
    static "\r\n"
  end
end

request :port do
  static "PORT"
  delim  " "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  static "\r\n"
end

request :lprt do
  static "LPRT"
  delim  " "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  delim  ", "
  byte   0, :format => :ascii
  static "\r\n"
end

request :lang do
  static "LANG"
  delim  " "
  string "fuzz"
  delim  "-"
  string "fuzz"
  static "\r\n"
end

request :eprt do
  static "EPRT"
  delim  " "
  delim  "|"
  byte   0, :format => :ascii
  delim  "|"
  byte   0, :format => :ascii
  delim  "."
  byte   0, :format => :ascii
  delim  "."
  byte   0, :format => :ascii
  delim  "."
  byte   0, :format => :ascii
  delim  "|"
  word   0, :format => :ascii
  static "\r\n"
end

request :epsv do
  static "EPSV"
  delim  " "
  byte   0, :format => :ascii
  delim  "."
  byte   0, :format => :ascii
  delim  "."
  byte   0, :format => :ascii
  delim  "."
  byte   0, :format => :ascii
  static "\r\n"
end

request :pbsz do
  static "PBSZ"
  delim  " "
  qword  0, :format => :ascii
  static "\r\n"
end

request :allo1 do
  static "ALLO"
  delim  " "
  qword  0, :format => :ascii
  static "\r\n"
end

request :allo2 do
  static "ALLO"
  delim  " "
  qword  0, :format => :ascii
  delim  " "
  static "R"
  delim  " "
  qword  0, :format => :ascii
  static "\r\n"
end

request :type1 do
  static "TYPE"
  delim  " "
  static "A"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :type2 do
  static "TYPE"
  delim  " "
  static "E"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :type3 do
  static "TYPE"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :type4 do
  static "TYPE"
  delim  " "
  static "L"
  delim  " "
  word   0, :format => :ascii
  static "\r\n"
end

request :appe do
  static "APPE"
  delim  " "
  string "fuzz"
  static "\r\n"
end

request :stor do
  static "STOR"
  delim  " "
  string "one.txt"
  static "\r\n"
end

request :nlst do
  static "NLST"
  delim  " "
  string "files"
  static "\r\n"
end

request :list do
  static "LIST"
  delim  " "
  string "files"
  static "\r\n"
end

request :retr do
  static "RETR"
  delim  " "
  string "one.txt"
  static "\r\n"
end

request :stou do
  static "STOU"
  delim  " "
  string "one.txt"
  static "\r\n"
end

request :rnto do
  static "RNTO"
  delim  " "
  string "one.txt"
  static "\r\n"
end

session :ftp, :logfile => 'tmp/ftp.log', :logfile_level => :error, :session_filename => 'tmp/ftp.state'

session :ftp do
  # commands directly accessible without login
  connect :auser
  connect :auser
  connect :apass
  connect :auser, :apass
  connect :ahelp
  connect :aacct
  connect :aprot
  connect :apbsz
  connect :ahost
  connect :aauth
  connect :aadat
  # authenticated commands
  connect :datauser
  connect :datauser, :datapass

  connect :datapass, :dataset1
  connect :datapass, :port
  connect :datapass, :type1
  connect :datapass, :type2
  connect :datapass, :type3
  connect :datapass, :type4
  connect :datapass, :allo1
  connect :datapass, :allo2
  connect :datapass, :pbsz
  connect :datapass, :eprt
  connect :datapass, :epsv
  connect :datapass, :lang
  connect :datapass, :eprt

  # special order of commands
  # PASS
  connect :datapass, :datapasv
  connect :datapasv, :appe
  connect :datapasv, :stor
  connect :datapasv, :nlst
  connect :datapasv, :list
  connect :datapasv, :retr
  connect :datapasv, :stou
  # PORT
  connect :datapass, :dataport
  connect :dataport, :appe
  connect :dataport, :stor
  connect :dataport, :nlst
  connect :dataport, :list
  connect :dataport, :retr
  connect :dataport, :stou
  # REST
  connect :datapass, :datarest
  connect :datarest, :appe
  connect :datarest, :stor
  connect :datarest, :retr
  # RNFR
  connect :datapass, :datarnfr
  connect :datarnfr, :rnto
end

session :ftp do
  target(
    :transport => {
        :type         => :tcp,
        :host         => '10.0.0.2',
        :port         => 21,
        :read_timeout => 0.1
      },
    :monitor => {
        :type         => :fortigate,
        :telnet_host  => '172.16.8.101' 
      }
  )
end

session :ftp do
  fuzz
end
