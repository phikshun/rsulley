########################################################################################################################
# Fuzz Accept header
# Accept: text/*;q=0.3, text/html;q=0.7, text/html;level=1, text/html;level=2;q=0.4, */*;q=0.5
########################################################################################################################

request :http_header_accept do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Accept"
  delim  ":"
  delim  " "
  string "text"
  delim  "/"
  string "*"
  delim  ";"
  string "q"
  delim  "="
  int    0, :format => :ascii
  delim  "."
  int    3, :format => :ascii
  delim  ", "
  delim  " "
  string "text"
  delim  "/"
  string "html"
  delim  ";"
  string "q"
  delim  "="
  int    0, :format => :ascii
  delim  "."
  int    7, :format => :ascii
  delim  ", "
  delim  " "
  string "text"
  delim  "/"
  string "html"
  delim  ";"
  string "level"
  delim  "="
  string "1"
  delim  ", "
  delim  " "
  string "text"
  delim  "/"
  string "html"
  delim  ";"
  string "level"
  delim  "="
  int    2, :format => :ascii
  delim  ";"
  string "q"
  delim  "="
  int    0, :format => :ascii
  delim  "."
  int    4, :format => :ascii
  delim  ", "
  delim  " "
  string "*"
  delim  "/"
  string "*"
  delim  ";"
  string "q"
  delim  "="
  int    0, :format => :ascii
  delim  "."
  int    5, :format => :ascii
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Accept-Charset header
# Accept-Charset: utf-8, unicode-1-1;q=0.8
########################################################################################################################

request :http_header_acceptcharset do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Accept-Charset"
  delim  ":"
  delim  " "
  string "utf"
  delim  "-"
  int    8, :format => :ascii
  delim  ", "
  delim  " "
  string "unicode"
  delim  "-"
  int    1, :format => :ascii
  delim  "-"
  int    1, :format => :ascii
  delim  ";"
  string "q"
  delim  "="
  int    0, :format => :ascii
  delim  "."
  int    8, :format => :ascii
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Accept-Datetime header
# Accept-Datetime: Thu, 31 May 2007 20:35:00 GMT
########################################################################################################################

request :http_header_acceptdatetime do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Accept-Datetime"
  delim  ":"
  delim  " "
  string "Thu"
  delim  ", "
  delim  " "
  string "31"
  delim  " "
  string "May"
  delim  " "
  string "2007"
  delim  " "
  string "20"
  delim  ":"
  string "35"
  delim  ":"
  string "00"
  delim  " "
  string "GMT"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Accept-Encoding header
# Accept-Encoding: gzip, deflate
########################################################################################################################

request :http_header_acceptencoding do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Accept-Encoding"
  delim  ":"
  delim  " "
  string "gzip"
  delim  ", "
  string "deflate"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Accept-Language header
# Accept-Language: en-us, en;q=0.5
########################################################################################################################

request :http_header_acceptlanguage do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Accept-Language"
  delim  ":"
  delim  " "
  string "en-us"
  delim  ", "
  string "en"
  delim  ";"
  string "q"
  delim  "="
  string "0.5"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Authorization header
# Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
########################################################################################################################

request :http_header_authorization do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Authorization"
  delim  ":"
  delim  " "
  string "Basic"
  delim  " "
  string "QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Cache-Control header
# Cache-Control: no-cache
########################################################################################################################

request :http_header_cachecontrol do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Cache-Control"
  delim  ":"
  delim  " "
  string "no"
  delim  "-"
  string "cache"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Connection header
# Connection: close
########################################################################################################################

request :http_header_close do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Connection"
  delim  ":"
  delim  " "
  string "close"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Content Length header
# Content-Length: 348
########################################################################################################################

request :http_header_contentlength do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Content-Length"
  delim  ":"
  delim  " "
  string "348"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Content MD5 header
# Content-MD5: Q2hlY2sgSW50ZWdyaXR5IQ==
########################################################################################################################

request :http_header_contentmd5 do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Content-MD5"
  delim  ":"
  delim  " "
  string "Q2hlY2sgSW50ZWdyaXR5IQ=="
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz COOKIE header
# Cookie: PHPSESSIONID=hLKQPySBvyTRq5K5RJmcTHQVtQycmwZG3Qvr0tSy2w9mQGmbJbJn;
########################################################################################################################

request :http_header_cookie do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"

  block :cookie do
    static "Cookie"
    delim  ":"
    delim  " "
    string "PHPSESSIONID"
    delim  "="
    string "hLKQPySBvyTRq5K5RJmcTHQVtQycmwZG3Qvr0tSy2w9mQGmbJbJn"
    static ";"
    static "\r\n"
  end

  repeat :cookie, :max => 5000, :step => 500
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Date header
# Date: Tue, 15 Nov 2012 08:12:31 EST
########################################################################################################################

request :http_header_date do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Date"
  delim  ":"
  delim  " "
  string "Tue"
  delim  ", "
  delim  " "
  string "15"
  delim  " "
  string "Nov"
  delim  " "
  string "2012"
  delim  " "
  string "08"
  delim  ":"
  string "12"
  delim  ":"
  string "31"
  delim  " "
  string "EST"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz DNT header -> May be same as X-Do-Not-Track?
# DNT: 1
########################################################################################################################

request :http_header_dnt do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "DNT"
  delim  ":"
  delim  " "
  string "1"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Expect header
# Expect: 100-continue
########################################################################################################################

request :http_header_expect do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Expect"
  delim  ":"
  delim  " "
  string "100"
  delim  "-"
  string "continue"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz From header
# From: derp@derp.com
########################################################################################################################

request :http_header_from do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "From"
  delim  ":"
  delim  " "
  string "derp"
  delim  "@"
  string "derp"
  delim  "."
  string "com"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Host header
# Host: 127.0.0.1
########################################################################################################################

request :http_header_host do
  static "GET / HTTP/1.1\r\n"
  static "Host"
  delim  ":"
  delim  " "
  dword  127, :format => :ascii
  delim  '.'
  dword  0, :format => :ascii
  delim  '.'
  dword  0, :format => :ascii
  delim  '.'
  dword  1, :format => :ascii
  static "\r\n"
  string "Connection"
  delim  ":"
  delim  " "
  string "Keep-Alive"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz If-Match header
# If-Match: "737060cd8c284d8af7ad3082f209582d"
########################################################################################################################

request :http_header_ifmatch do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "If-Match"
  delim  ":"
  delim  " "
  static "\""
  string "737060cd8c284d8af7ad3082f209582d"
  static "\""
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz If-Modified-Since header
# If-Modified-Since: Sat, 29 Oct 2012 19:43:31 ESTc
########################################################################################################################

request :http_header_ifmodifiedsince do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "If-Modified-Since"
  delim  ":"
  delim  " "
  string "Sat"
  delim  ", "
  delim  " "
  string "29"
  delim  " "
  string "Oct"
  delim  " "
  string "2012"
  delim  " "
  string "08"
  delim  ":"
  string "12"
  delim  ":"
  string "31"
  delim  " "
  string "EST"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz If-None-Match header
# If-None-Match: "737060cd8c284d8af7ad3082f209582d"
########################################################################################################################

request :http_header_ifnonematch do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "If-None-Match"
  delim  ":"
  delim  " "
  static "\""
  string "737060cd8c284d8af7ad3082f209582d"
  static "\""
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz If-Range header
# If-Range: "737060cd8c284d8af7ad3082f209582d"
########################################################################################################################

request :http_header_ifrange do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "If-Range"
  delim  ":"
  delim  " "
  static "\""
  string "737060cd8c284d8af7ad3082f209582d"
  static "\""
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz If-Unmodified-Since header
# If-Unmodified-Since: Sat, 29 Oct 2012 19:43:31 EST
########################################################################################################################

request :http_header_ifunmodifiedsince do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "If-Unmodified-Since"
  delim  ":"
  delim  " "
  string "Sat"
  delim  ", "
  delim  " "
  string "29"
  delim  " "
  string "Oct"
  delim  " "
  string "2012"
  delim  " "
  string "08"
  delim  ":"
  string "12"
  delim  ":"
  string "31"
  delim  " "
  string "EST"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz KeepAlive header
# Keep-Alive: 300
########################################################################################################################

request :http_header_keepalive do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Keep-Alive"
  delim  ":"
  delim  " "
  string "300"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Max-Fowards header
# Max-Forwards: 80
########################################################################################################################

request :http_header_maxforwards do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Max-Forwards"
  delim  ":"
  delim  " "
  string "80"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Pragma header
# Pragma: no-cache
########################################################################################################################

request :http_header_pragma do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Pragma"
  delim  ":"
  delim  " "
  string "no-cache"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Proxy-Authorization header
# Proxy-Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
########################################################################################################################

request :http_header_proxyauthorization do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Proxy-Authorization"
  delim  ":"
  delim  " "
  string "Basic"
  delim  " "
  string "QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Range header
# Range: bytes=500-999
########################################################################################################################

request :http_header_range do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Range"
  delim  ":"
  delim  " "
  string "bytes"
  delim  "="
  string "500"
  delim  "-"
  string "999"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Referer header
# Referer: http://172.16.8.101
########################################################################################################################

request :http_header_referer do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Referer"
  delim  ":"
  delim  " "
  string "http://172.16.8.101"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz TE header
# TE: trailers, deflate
########################################################################################################################

request :http_header_te do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "TE"
  delim  ":"
  delim  " "
  string "trailers"
  delim  ", "
  delim  " "
  string "deflate"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Upgrade header
# Upgrade: HTTP/2.0, SHTTP/1.3, IRC/6.9, RTA/x11
########################################################################################################################

request :http_header_upgrade do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Upgrade"
  delim  ":"
  delim  " "
  string "HTTP"
  delim  "/"
  string "2"
  delim  "."
  string "0"
  delim  ", "
  delim  " "
  string "SHTTP"
  delim  "/"
  string "1"
  delim  "."
  string "3"
  delim  ", "
  delim  " "
  string "IRC"
  delim  "/"
  string "6"
  delim  "."
  string "9"
  delim  ", "
  delim  " "
  string "RTA"
  delim  "/"
  string "x11"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz User Agent header
# User-Agent: Mozilla/5.0 (Windows; U)
########################################################################################################################

request :http_header_useragent do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "User-Agent"
  delim  ":"
  delim  " "
  string "Mozilla/5.0 (Windows; U)"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Via header
# Via: 1.0 derp, 1.1 derp.com (Apache/1.1)
########################################################################################################################

request :http_header_via do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Via"
  delim  ":"
  delim  " "
  string "1"
  delim  "."
  string "0"
  delim  " "
  string "derp"
  delim  ", "
  delim  " "
  string "1"
  delim  "."
  string "1"
  delim  " "
  string "derp.com"
  delim  " "
  delim  "("
  string "Apache"
  delim  "/"
  string "1"
  delim  "."
  string "1"
  delim  ")"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz Warning header
# Warning: 4141 Sulley Rocks!
########################################################################################################################

request :http_header_warning do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Warning"
  delim  ":"
  delim  " "
  string "4141"
  delim  " "
  string "Sulley Rocks!"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz X-att-deviceid header
# x-att-deviceid: DerpPhone/Rev2309
########################################################################################################################

request :http_header_xattdeviceid do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "x-att-deviceid"
  delim  ":"
  delim  " "
  string "DerpPhone"
  delim  "/"
  string "Rev2309"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz X-Do-Not-Track header
# X-Do-Not-Track: 1
########################################################################################################################

request :http_header_xdonottrack do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "X-Do-Not-Track"
  delim  ":"
  delim  " "
  string "1"
  static "\r\n\r\n"

end

########################################################################################################################
# Fuzz X-Forwarded-For header
# X-Forwarded-For: client1, proxy1, proxy2
########################################################################################################################

request :http_header_xforwardedfor do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "X-Forwarded-For"
  delim  ":"
  delim  " "
  string "client1"
  delim  ", "
  delim  " "
  string "proxy2"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz X-Requested-With header
# X-Requested-With: XMLHttpRequest
########################################################################################################################

request :http_header_xrequestedwith do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "X-Requested-With"
  delim  ":"
  delim  " "
  string "XMLHttpRequest"
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz X-WAP-Profile header
# x-wap-profile: http://wap.samsungmobile.com/uaprof/SGH-I777.xml
########################################################################################################################

request :http_header_xwapprofile do
  static "GET / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "x-wap-profile"
  delim  ":"
  delim  " "
  string "http"
  delim  ":"
  delim  "/"
  delim  "/"
  string "wap.samsungmobile.com/uaprof/SGH-I777"
  static ".xml"
  static "\r\n\r\n"
end
