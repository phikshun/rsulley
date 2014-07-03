# rsulley script to test smtp handling
# needs to be optimized

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

request :starttls do
  static "STARTTLS"
  static "\r\n"
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
  
  group  :mail_from_cmd1, 'BODY', 'TRANSID', 'AUTH', 'BY', 'RET', 'ENVID', 'MT-PRIORITY', 
                          'MTRK', 'SMTPUTF8', 'SUBMITTER'
  
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
  static "MAIL FROM"
  delim  ':'
  delim  '<'
  string 'test'
  delim  '@'
  string 'testdomain'
  delim  '.'
  string 'com'
  delim  '>'
  static "\r\n"
  
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
  
  static "DATA"
  static "\r\n"
  
  string 'Subject'
  delim  ':'
  delim  ' '
  string 'fuzz'
  static "\r\n"
  
  group  :headers, 'cc', 'bcc', 'DL-Expansion-History', 'Path', 'Received', 'Return-Path', 'Content-Disposition',
                   'Alternate-Recipient', 'Message-Context', 'Disclose-Recipients', 'MIME-Version',
                   'Original-Encoded-Information-Types', 'Apparently-To', 'Distribution', 'From', 'Originator-Info',
                   'Sender', 'To', 'X-Envelope-From', 'X-Envelope-To', 'X-RCPT-TO', 'X-Sender', 'X-X-Sender',
                   'Content-Return', 'Disposition-Notification-Options', 'Disposition-Notification-To',
                   'Followup-To', 'Generate-Delivery-Report', 'Original-Recipient', 'Prevent-NonDelivery-Report',
                   'Reply-To', 'Mail-Followup-To', 'Mail-Reply-To', 'Date', 'Delivery-Date', 'Expires',
                   'Expiry-Date', 'Reply-By', 'Importance', 'Priority', 'X-MSMail-Priority', 'X-Priority',
                   'Content-Length', 'Lines', 'Content-Alternative', 'Conversion', 'Content-Transfer-Encoding',
                   'Content-Type', 'Encoding', 'Message-Type', 'Status', 'X-No-Archive', 'Delivered-To',
                   'X-Received By', 'Message-id', 'Dkim-Signature', 'Authentication-Results', 'Received-Spf',
                   'X-Sg-Eid', 'X-Originating-Ip', 'Accept-Language', 'Content-Language'

  block  :header_values, :group => :headers do
    delim  ':'
    delim  ' '
    string 'fuzz'
    static "\r\n"
  end
  
  string 'B' * 1000
  static "\r\n"
  delim  '.'
  static "\r\n"
  
  string "QUIT"
  static "\r\n"
end

session :smtp, :logfile => 'tmp/smtp.log', :logfile_level => :error, :session_filename => 'tmp/smtp.state'

session :smtp do
  connect :helo
  connect :ehlo
  connect :helo, :starttls
  connect :ehlo, :starttls
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
  connect :ehlo, :mail_from_with_size
  connect :ehlo, :mail_from_with_cmd1
  
  connect :mail_from,           :rcpt_to
  connect :mail_from,           :rcpt_to_with_cmd1
  connect :rcpt_to,             :data
  connect :rcpt_to,             :bdat
  connect :rcpt_to,             :burl
  connect :bdat,                :message
  connect :data,                :message
  connect :message,             :quit
  
  connect :ehlo, :smtp_complete1
end

# dump udraw diagram of session graph
#
#session :smtp do
#  File.open 'smtp.udg', 'w' do |f|
#    f.write render_graph_udraw
#  end
#end
#
#exit

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
