module RSulley

# TODO: need to add options for max read bytes, or read stop string/regex (for readline like operation)
#       or a lambda with a parser function provided
  
class BasicTransport
  attr_accessor :host, :port, :sock, :logger
    
  def initialize(opts = {})
    @host = opts[:host]
    @port = opts[:port]
    
    @logger           = opts[:logger]           || Logger.logging(STDOUT)
    @write_timeout    = opts[:write_timeout]    || 1
    @read_timeout     = opts[:read_timeout]     || 1
    @connect_timeout  = opts[:connect_timeout]  || 2
    
    @sock = nil
  end
  
  def open; end
  def write(data); end
  def read(bytes = 1); end
  def close; end
end

class TcpTransport < BasicTransport
  attr_accessor :host, :port, :sock, :logger
  
  def open
    Timeout.timeout(@connect_timeout) { @sock = TCPSocket.new @host, @port }; self
  rescue SystemCallError, Timeout::Error => e
    logger.error "connect failed - #{e.message}"; nil
  end
  
  def write(data)
    return nil if @sock.nil? || @sock.closed?
    Timeout.timeout(@write_timeout) { @sock.write(data) }; self
  rescue SystemCallError, OpenSSL::SSL::SSLError => e
    logger.error "write failed - #{e.message}"; nil
  rescue Timeout::Error
    logger.warn "write timeout"; nil
  end
  
  def read(bytes = 1)
    return '' if @sock.nil? || @sock.closed?
    @buf = ''
    Timeout.timeout(@read_timeout) do 
      loop { @buf += @sock.read(bytes) }
    end
    @buf
  rescue SystemCallError, EOFError => e
    logger.warn "read failed - #{e.message}"; @buf
  rescue Timeout::Error
    logger.debug "read timeout"; @buf 
  end
  
  def close
    return if @sock.nil? || @sock.closed?
    @sock.close
    @sock = nil
    self
  end
end

class SslTransport < TcpTransport
  attr_accessor :host, :port, :sock, :logger
  
  def initialize(opts = {})
    super
    
    @ssl_ca       = opts[:ssl_ca]
    @ssl_cert     = opts[:ssl_cert]
    @ssl_key      = opts[:ssl_key]
    @ssl_version  = opts[:ssl_version] || :TLSv1
    
    @ssl_server_mode = opts[:ssl_server_mode]
  end
  
  def open
    @sock = super
  
    ssl_context = OpenSSL::SSL::SSLContext.new
    ssl_context.ssl_version = @ssl_version
    if @ssl_ca
      ssl_context.ca_file = @ssl_ca
      ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER|OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
    else
      ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    
    if @ssl_cert && @ssl_key
      ssl_context.cert = OpenSSL::X509::Certificate.new(File.open(@ssl_cert))
      ssl_context.key = OpenSSL::PKey::RSA.new(File.open(@ssl_key))
    end
    
    @sock = OpenSSL::SSL::SSLSocket.new(@sock, ssl_context)
    @sock.sync_close = true
    
    if @ssl_server_mode
      Timeout.timeout(@connect_timeout) { @sock.accept }
    else
      Timeout.timeout(@connect_timeout) { @sock.connect }
    end
    self
  rescue SystemCallError, OpenSSL::SSL::SSLError => e
    logger.error "ssl connect failed - #{e.message}"; nil
  rescue Timeout::Error
    logger.error "ssl connect timeout"; nil
  end
end

class UdpTransport < BasicTransport
  attr_accessor :host, :port, :sock, :logger
  
  def open
    # open udp socket
  end
  
  def write(data)
    # use sendto
  end
  
  def read(bytes = 1500)
  end
  
  def close
  end
end

end