def http_reader(socket)
  buf = ''
  transfer_encoding_chunked = false
  content_length = nil
  
  begin
    buf += socket.readline # read the status line and CRLF
    
    resp_headers = {}
    until ((data = socket.readline).chop!).empty?
      buf += data
      key, value = data.split(/:\s*/, 2)
      resp_headers[key] = ([*resp_headers[key]] << value).compact.join(', ')
      if key.casecmp('Content-Length') == 0
        content_length = value.to_i
      elsif key.casecmp('Transfer-Encoding') == 0 && value.casecmp('chunked') == 0
        transfer_encoding_chunked = true
      end
    end

    if transfer_encoding_chunked
      while (chunk_size = socket.readline.chop!.to_i(16)) > 0
        buf += socket.read(chunk_size + 2).chop! # 2 == "/r/n".length
      end
      socket.read(2) # 2 == "/r/n".length
    elsif remaining = content_length
      while remaining > 0
        buf += socket.read([1048576, remaining].min)
        remaining -= 1048576
      end
    else
      buf += socket.read
    end
  end
  
  buf
end

########################################################################################################################
# Fuzz all the publicly avalible methods known for HTTP Servers
########################################################################################################################

request :http_verbs do
  group  :verbs, "GET", "HEAD", "POST", "OPTIONS", "TRACE", "PUT", "DELETE", "PROPFIND", "CONNECT", "PROPPATCH",
                 "MKCOL", "COPY", "MOVE", "LOCK", "UNLOCK", "VERSION-CONTROL", "REPORT", "CHECKOUT", 
                 "CHECKIN", "UNCHECKOUT", "MKWORKSPACE", "UPDATE", "LABEL", "MERGE", "BASELINE-CONTROL",
                 "MKACTIVITY", "ORDERPATCH","ACL" ,"PATCH", "SEARCH", "CAT"
                 
  block :body, :group => :verbs do
    delim  " "
    delim  "/"
    string "index.html"
    delim  " "
    string "HTTP"
    delim  "/"
    int    1, :format => :ascii
    delim  "."
    int    1, :format => :ascii
    static "\r\n"
    static "Host: 172.16.8.101"
    static "\r\n\r\n"
  end
end

########################################################################################################################
# Fuzz the HTTP Method itself
########################################################################################################################

request :http_method do
  string "FUZZ"
  static " /index.html HTTP/1.1"
  static "\r\n"
  static "Host: 172.16.8.101"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz this standard multi-header HTTP request
# GET / HTTP/1.1
# Host: 172.16.8.101
# Connection: keep-alive
# User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.83 Safari/537.1
# Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
# Accept-Encoding: gzip,deflate,sdch
# Accept-Language: en-US,en;q=0.8
# Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3
########################################################################################################################

request :http_req do
  static "GET / HTTP/1.1\r\n"
# Host: 172.16.8.101
  static "Host"
  delim  ":"
  delim  " "
  string "172.16.8.101"
  static "\r\n"
# Connection: keep-alive
  static "Connection"
  delim  ":"
  delim  " "
  string "Keep-Alive"
# User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.83 Safari/537.1
  static "User-Agent"
  delim  ":"
  delim  " "
  string "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.83 Safari/537.1"
  static "\r\n"
# Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
  static "Accept"
  delim  ":"
  delim  " "
  string "text"
  delim  "/"
  string "html"
  delim  ", "
  string "application"
  delim  "/"
  string "xhtml"
  delim  "+"
  string "xml"
  delim  ", "
  string "application"
  delim  "/"
  string "xml"
  delim  ";"
  string "q"
  delim  "="
  int    0, :format => :ascii
  delim  "."
  int    9, :format => :ascii
  delim  ", "
  string "*"
  delim  "/"
  string "*"
  delim  ";"
  string "q"
  delim  "="
  int    0, :format => :ascii
  delim  "."
  int    8, :format => :ascii
  static "\r\n"
# Accept-Encoding: gzip,deflate,sdch
  static "Accept-Encoding"
  delim  ":"
  delim  " "
  string "gzip"
  delim  ", "
  string "deflate"
  delim  ", "
  string "sdch"
  static "\r\n"
# Accept-Language: en-US,en;q=0.8
  static "Accept-Language"
  delim  ":"
  delim  " "
  string "en-US"
  delim  ", "
  string "en"
  delim  ";"
  string "q"
  delim  "="
  string "0.8"
  static "\r\n"
# Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3
  static "Accept-Charset"
  delim  ":"
  delim  " "
  string "ISO"
  delim  "-"
  int    8859, :format => :ascii
  delim  "-"
  int    1, :format => :ascii
  delim  ", "
  string "utf-8"
  delim  ";"
  string "q"
  delim  "="
  int    0, :format => :ascii
  delim  "."
  int    7, :format => :ascii
  delim  ", "
  string "*"
  delim  ";"
  string "q"
  delim  "="
  int    0, :format => :ascii
  delim  "."
  int    3, :format => :ascii
  static "\r\n\r\n"
end
