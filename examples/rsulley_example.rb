$: << '../lib/rsulley'
require 'rsulley'
include RSulley

request :http_basic do
  group :verbs, "GET", "HEAD", "POST", "TRACE"
  
  block :body, :group => :verbs do
    delim   ' '
    delim   '/'
    string  'index.html'
    delim   ' '
    string  'HTTP'
    delim   '/'
    string  '1'
    delim   '.'
    string  '1'
    static  "\r\n\r\n"
  end
end

while r.mutate do p r.render; end

=begin
request :my_proto do
  block :table_entry do
    random  "\x00\x00", :min_length => 2, :max_length => 2
    size    :string_field, :length => 4
    
    block :string_field do
      string 'C' * 10
    end
    
    checksum :string_field, :algorithm => :crc32
  end
  
  repeat :table_entry, :min_reps => 1, :max_reps => 4, :step => 1
end

sess = Session.new
sess.connect helo
sess.connect ehlo
sess.connect helo, mail_from
sess.connect ehlo, mail_from
sess.connect mail_from, rcpt_to
sess.connect rcpt_to, data

File.open "session_test.udg", 'w' do |f|
  f.write sess.render_as_graph
end

target = Target.new('10.0.0.1', 5168, :ssl => true, :cert => 'certs/cert.pem', :key => 'certs/key.pem')

target.monitor = FortigateMonitor

sess.add_target(target)
sess.fuzz!
=end



    