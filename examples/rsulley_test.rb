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

request :mail_from do
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

request :data do
  static "DATA"
  static "\r\n"
end

request :message do
  static 'Subject'
  delim  ':'
  delim  ' '
  string 'Test'
  static "\r\n"
  string "Test Message"
  static "\r\n"
  delim  '.'
  static "\r\n"
end

request :quit do
  static "QUIT"
  static "\r\n"
end

session :smtp, :session_filename => 'rsulley.state'

session(:smtp).connect get(:helo)
session(:smtp).connect get(:ehlo)
session(:smtp).connect get(:helo),      get(:mail_from)
session(:smtp).connect get(:ehlo),      get(:mail_from)
session(:smtp).connect get(:mail_from), get(:rcpt_to)
session(:smtp).connect get(:rcpt_to),   get(:data)
session(:smtp).connect get(:data),      get(:message)
session(:smtp).connect get(:message),   get(:quit)

session(:smtp).target(
  :transport => 
    {
      :type => :tcp,
      :host => 'localhost',
      :port => 25
    }
)

session(:smtp).fuzz
