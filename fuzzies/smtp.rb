# short rsulley script to test basic smtp handling

request :helo do
  static "HELO"
  delim  ' '
  string "testdomain"
  delim  '.'
  string 'com'
  static "\r\n"
end

request :ehlo do
  static "EHLO"
  delim  ' '
  string "testdomain"
  delim  '.'
  string 'com'
  static "\r\n"
end

request :help do
  static "HELP"
  delim  ' '
  string "fuzz"
  static "\r\n"
end

request :noop do
  static "NOOP"
  delim  ' '
  string "fuzz"
  static "\r\n"
end

request :verb do
  static "VERB"
  delim  ' '
  string "fuzz"
  static "\r\n"
end

request :turn do
  static "TURN"
  delim  ' '
  string "fuzz"
  static "\r\n"
end

request :rset do
  static "RSET"
  delim  ' '
  string "fuzz"
  static "\r\n"
end

request :expn do
  static "EXPN"
  delim  ' '
  string "fuzz"
  static "\r\n"
end

request :vrfy do
  static "VRFY"
  delim ' '
  string "fuzz"
  static "\r\n"
end

request :bdat do
  static 'BDAT'
  delim  ' '
  int    86, :format => :ascii
  delim  ' '
  string 'LAST'
  static "\r\n"
end

request :burl do
  static 'BURL'
  delim  ' '
  string 'imap'
  delim  ':'
  delim  '//'
  string 'harry'
  delim  '@'
  string 'example'
  delim  '.'
  string 'com'
  delim  '/'
  string 'outbox'
  static "\r\n"
  delim  '           '
  delim  ';'
  string 'uidvalidity'
  delim  '='
  int    1078863300, :format => :ascii
  delim  ';'
  string 'uid'
  delim  '='
  int    25, :format => :ascii
  delim  ';'
  string 'urlauth'
  delim  '='
  string 'submit+harry'
  static "\r\n"
  delim  '           '
  delim  ':'
  string 'internal'
  delim  ':'
  string '91354a473744909de610943775f92038'
  delim  ' '
  string 'LAST'
  static "\r\n"
end

request :auth do
  static 'AUTH'
  delim  ' '
  group  :auth_methods, 'GSSAPI', 'DIGEST-MD5', 'PLAIN', 'CRAM-MD5', 'EXTERNAL'
  
  block  :auth_block, :group => :auth_methods do
    static "\r\n"
    string "password"
  end
  static "\r\n"
end

request :atrn do
  static 'ATRN'
  delim  ' '
  string 'example'
  delim  '.'
  string 'org'
  delim  ','
  string 'testdomain'
  delim  '.'
  string 'com'
  static "\r\n"
end

request :mail_from do
  group :mail_verbs, 'MAIL', 'SEND', 'SOML', 'SAML'
  
  block :mail_with_verbs, :group => :mail_verbs do
    delim  ' '
    string "FROM"
    delim  ':'
    delim  '<'
    string 'test'
    delim  '@'
    string 'testdomain'
    delim  '.'
    string 'com'
    delim  '>'
    static "\r\n"
  end
end

request :mail_from_with_size do
  static "MAIL FROM"
  delim  ':'
  delim  '<'
  string 'test'
  delim  '@'
  string 'testdomain'
  delim  '.'
  string 'com'
  delim  '>'
  delim  ' '
  static 'SIZE'
  delim  '='
  int    1000, :format => :ascii
  static "\r\n"
end

request :mail_from_with_cmd1 do
  static "MAIL FROM"
  delim  ':'
  delim  '<'
  string 'test'
  delim  '@'
  string 'testdomain'
  delim  '.'
  string 'com'
  delim  '>'
  delim  ' '
  
  group  :mail_from_cmd1, 'BODY', 'TRANSID', 'AUTH', 'BY', 'RET', 'ENVID', 'MT-PRIORITY', 'MTRK'
  
  block  :mail_from_cmd1_blk, :group => :mail_from_cmd1 do
    delim  '='
    string '8BITMIME'
  end
  
  static "\r\n"
end

request :rcpt_to do
  static "RCPT TO"
  delim  ':'
  delim  '<'
  string 'test'
  delim  '@'
  string 'yourdomain'
  delim  '.'
  string 'com'
  delim  '>'
  static "\r\n"
end

request :rcpt_to_with_cmd1 do
  static "RCPT TO"
  delim  ':'
  delim  '<'
  string 'test'
  delim  '@'
  string 'yourdomain'
  delim  '.'
  string 'com'
  delim  '>'
  delim  ' '
  
  group  :rcpt_to_cmd1, 'CONPERM', 'CONNEG', 'NOTIFY'
  
  block  :rcpt_to_cmd1_blk, :group => :rcpt_to_cmd1 do
    delim  '='
    string 'fuzz'
  end
  
  static "\r\n"
end

request :data do
  static "DATA"
  static "\r\n"
end

request :message do
  static 'Subject'
  delim  ':'
  delim  ' '
  string 'A' * 50
  static "\r\n"
  string 'B' * 1000
  static "\r\n"
  delim  '.'
  static "\r\n"
end

request :quit do
  static "QUIT"
  static "\r\n"
  string ''
end

request :smtp_complete1 do
  string "MAIL FROM"
  delim  ':'
  delim  '<'
  string 'test'
  delim  '@'
  string 'testdomain'
  delim  '.'
  string 'com'
  delim  '>'
  static "\r\n"
  
  string "RCPT TO"
  delim  ':'
  delim  '<'
  string 'test'
  delim  '@'
  string 'yourdomain'
  delim  '.'
  string 'com'
  delim  '>'
  static "\r\n"
  
  string "DATA"
  static "\r\n"
  
  string 'Subject'
  delim  ':'
  delim  ' '
  string 'A' * 50
  static "\r\n"
  string 'B' * 1000
  static "\r\n"
  delim  '.'
  static "\r\n"
  
  string "QUIT"
  static "\r\n"
end

session :smtp, :logfile => 'tmp/smtp.log', :logfile_level => :error, :session_filename => 'tmp/smtp1.state'

session :smtp do
  connect :helo
  connect :ehlo
  connect :helo, :help
  connect :ehlo, :help
  connect :helo, :turn
  connect :ehlo, :turn
  connect :helo, :verb
  connect :ehlo, :verb
  connect :helo, :noop
  connect :ehlo, :noop
  connect :helo, :expn
  connect :ehlo, :expn
  connect :helo, :vrfy
  connect :ehlo, :vrfy
  connect :helo, :rset
  connect :ehlo, :rset
  connect :helo, :atrn
  connect :ehlo, :atrn
  connect :helo, :auth
  connect :ehlo, :auth
  connect :helo, :mail_from
  connect :ehlo, :mail_from
  connect :helo, :mail_from_with_size
  connect :ehlo, :mail_from_with_size
  connect :helo, :mail_from_with_cmd1
  connect :auth, :mail_from
  
  connect :mail_from,           :rcpt_to
  connect :mail_from_with_size, :rcpt_to
  connect :mail_from_with_cmd1, :rcpt_to
  connect :mail_from,           :rcpt_to_with_cmd1
  connect :mail_from_with_size, :rcpt_to_with_cmd1
  connect :mail_from_with_cmd1, :rcpt_to_with_cmd1
  connect :rcpt_to,             :data
  connect :rcpt_to,             :bdat
  connect :rcpt_to,             :burl
  connect :rcpt_to_with_cmd1,   :data
  connect :rcpt_to_with_cmd1,   :bdat
  connect :rcpt_to_with_cmd1,   :burl
  connect :bdat,                :message
  connect :data,                :message
  connect :burl,                :quit
  connect :message,             :quit
  
  connect :helo, :smtp_complete1
  connect :ehlo, :smtp_complete1
end

session :smtp do
  File.open 'smtp.udg', 'w' do |f|
    f.write render_graph_udraw
  end
end

exit

session :smtp do
  target(
    :transport => {
        :type         => :tcp,
        :host         => '10.0.0.2',
        :port         => 25,
        :read_timeout => 0.1
      },
    :monitor => {
        :type         => :fortigate,
        :telnet_host  => '172.16.8.101' 
      }
  )
end

session :smtp do
  fuzz
end
