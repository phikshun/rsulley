########################################################################################################################
# Fuzz POST requests with most MIMETypes known
########################################################################################################################

request :http_verbs_post_all do
  static "POST / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Content-Type: "
  group  :mimetypes, "audio/basic", "audio/x-mpeg", "drawing/x-dwf", "graphics/x-inventor", "image/x-portable-bitmap",
                     "message/external-body","message/http","message/news","message/partial","message/rfc822",
                     "multipart/alternative","multipart/appledouble","multipart/digest","multipart/form-data",
                     "multipart/header-set","multipart/mixed","multipart/parallel","multipart/related","multipart/report",
                     "multipart/voice-message","multipart/x-mixed-replace","text/css","text/enriched","text/html",
                     "text/javascript","text/plain","text/richtext","text/sgml","text/tab-separated-values","text/vbscript",
                     "video/x-msvideo","video/x-sgi-movie","workbook/formulaone","x-conference/x-cooltalk","x-form/x-openscape",
                     "x-music/x-midi","x-script/x-wfxclient","x-world/x-3dmf"
                     
  block :mime, :group => :mimetypes do
    static "\r\n"
    static "Content-Length: "
    size   :post_blob, :format => :ascii, :signed => true, :fuzzable => true
    static "\r\n\r\n"
  end

  block :post_blob do
    string "A"*100 + "=" + "B"*100
  end
  static "\r\n\r\n"
end

########################################################################################################################
# Basic fuzz of post payloads
########################################################################################################################

request :http_verbs_post do
  static "POST / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Content-Type: "
  string "application/x-www-form-urlencoded"
  static "\r\n"
  static "Content-Length: "
  size   :post_blob, :format => :ascii, :signed => true, :fuzzable => true
  static "\r\n"
  block :post_blob do
    string "A"*100 + "=" + "B"*100
  end
  static "\r\n\r\n"
end

########################################################################################################################
# Fuzz POST request MIMETypes
########################################################################################################################

request :http_verbs_post_req do
  static "POST / HTTP/1.1\r\n"
  static "Host: 172.16.8.101\r\n"
  static "Content-Type: "
  string "application"
  delim  "/"
  string "x"
  delim  "-"
  string "www"
  delim  "-"
  string "form"
  delim  "-"
  string "urlencoded"
  static "\r\n"
  static "Content-Length: "
  size   :post_blob, :format => :ascii, :signed => true, :fuzzable => true
  static "\r\n"
  block :post_blob do
    string "A"*100 + "=" + "B"*100
  end
  static "\r\n\r\n"
end