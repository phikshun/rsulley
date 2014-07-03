require 'requests/http_get'
require 'requests/http_post'
require 'requests/http_header'

requests = [
  :http_verbs,
  :http_method,
  :http_req,
  :http_verbs_post_all,
  :http_verbs_post,
  :http_verbs_post_req,
  :http_header_host,
  :http_header_accept,
  :http_header_acceptcharset,
  :http_header_acceptdatetime,
  :http_header_acceptencoding,
  :http_header_acceptlanguage,
  :http_header_authorization,
  :http_header_cachecontrol,
  :http_header_close,
  :http_header_contentlength,
  :http_header_contentmd5,
  :http_header_cookie,
  :http_header_date,
  :http_header_dnt,
  :http_header_expect,
  :http_header_from,
  :http_header_ifmatch,
  :http_header_ifmodifiedsince,
  :http_header_ifnonematch,
  :http_header_ifrange,
  :http_header_ifunmodifiedsince,
  :http_header_keepalive,
  :http_header_maxforwards,
  :http_header_pragma,
  :http_header_proxyauthorization,
  :http_header_range,
  :http_header_referer,
  :http_header_te,
  :http_header_upgrade,
  :http_header_useragent,
  :http_header_via,
  :http_header_warning,
  :http_header_xattdeviceid,
  :http_header_xdonottrack,
  :http_header_xforwardedfor,
  :http_header_xrequestedwith,
  :http_header_xwapprofile
]

session :http, :logfile => 'tmp/http.log', :logfile_level => :error, :session_filename => 'tmp/http.state'

requests.each do |req|
  session :http do
    connect req
  end
end

session :http do
  target(
    :transport => {
        :type         => :tcp,
        :host         => '172.16.8.101',
        :port         => 80,
        :reader       => ->(s) { http_reader(s) }
      },
    :monitor => {
        :type         => :fortigate,
        :telnet_host  => '172.16.8.101' 
      }
  )
end

session :http do
  fuzz
end