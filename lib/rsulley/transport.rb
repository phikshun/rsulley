module RSulley
  
class BasicTransport
  extend Forwardable
  attr_accessor :host, :port, :sock, :logger
  
  def_delegators(:@sock, :readline, :readline)
      
  def initialize(target, opts = {})
    @host = target.host
    @port = target.port
    
    @logger           = opts[:logger]           || Logger.logging(STDOUT)
    @write_timeout    = opts[:write_timeout]    || 2
    @read_timeout     = opts[:read_timeout]     || 2
    @connect_timeout  = opts[:connect_timeout]  || 2
    
    @sock = nil
  end
  
  def open; end
  def write(data); end
  def read(max = 10000); end
  def close; end
end

class TcpTransport < BasicTransport
  attr_accessor :host, :port, :sock, :logger
  
  def open
    Timeout.timeout(@connect_timeout) { @sock = TCPSocket.new @host, @port }; self
  rescue SystemCallError, Timeout::Error => e
    logger.warn "connect failed - #{e.message}"; nil
  end
  
  def write(data)
    return nil if @sock.nil? || @sock.closed?
    Timeout.timeout(@write_timeout) { @sock.write(data) }; self
  rescue SystemCallError, OpenSSL::SSL::SSLError => e
    logger.warn "write failed - #{e.message}"; nil
  rescue Timeout::Error
    logger.warn "write timeout"; nil
  end
  
  def read(max = 10000)
    return if @sock.nil? || @socket.closed?
    @buf = ''
    Timeout.timeout(@read_timeout) { @buf += @sock.read(max) }; @buf
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
  
  def initialize(target, opts = {})
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
    
    if @ssl_server_mode
      Timeout.timeout(@connect_timeout) { @sock.accept }
    else
      Timeout.timeout(@connect_timeout) { @sock.connect }
    end
    self
  rescue SystemCallError, OpenSSL::SSL::SSLError => e
    logger.warn "ssl connect failed - #{e.message}"; nil
  rescue Timeout::Error
    logger.warn "ssl connect timeout"; nil
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
  
  def read(max = 1500)
  end
  
  def close
  end
end

end