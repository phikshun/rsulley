module RSulley
  
class BasicMonitor
  attr_accessor :crash_synopsis, :logger, :elapsed, :current_mutant_index
  
  def initialize(opts = {})
    @logger     = opts[:logger] || Logger.logging(STDOUT)
    @start_time = Time.now
    @elapsed    = 0.0
  end
  
  def start(mutant_index)
    @current_mutant_index = mutant_index
    @start_time           = Time.now
  end
  
  def finish
    @elapsed = Time.now - @start_time
  end
  
  def check
    false
  end
  
  def close
  end
end

class FortigateMonitor < BasicMonitor
  def initialize(opts = {})
    super
    
    @telnet_host    = opts[:telnet_host]
    @telnet_port    = opts[:telnet_port]    || 23
    @telnet_prompt  = opts[:telnet_prompt]  || /[a-zA-Z0-9]+ # \z/in
    @telnet_user    = opts[:telnet_user]    || 'admin'
    @telnet_pass    = opts[:telnet_pass]    || ''
    
    telnet_login
    telnet_cmd('diag debug crash clear')
  end
  
  def telnet_login
    @telnet = Net::Telnet.new "Host" => @telnet_host, "Port" => @telnet_port, "Prompt" => @telnet_prompt
    @telnet.login @telnet_user, @telnet_pass
  rescue Errno::ETIMEDOUT, Timeout::Error => e
    logger.error "telnet could not connect to target #{@telnet_host}:#{@telnet_port} - #{e.message}"
    logger.debug "backtrace:\n#{e.backtrace}"
    sleep(1)
    retry
  end
  
  def telnet_cmd(cmd, &block)
    if block_given?
      @telnet.cmd(cmd, &block)
    else
      @telnet.cmd(cmd)
    end
  rescue Errno::ETIMEDOUT, Timeout::Error => e
    logger.warn "telnet logged out... retrying"
    login
  end
  
  def check
    telnet_cmd('diag debug crash read') do |output|
      if output && output.length > 300
        @crash_synopsis = output
        telnet_cmd('diag debug crash clear')
        return output
      elsif output && output.length > 80
        telnet_cmd('diag debug crash clear')
      end
    end
    @crash_synopsis = nil
    return nil
  end
  
  def close
    telnet_cmd('diag debug crash clear')
    telnet_cmd('exit')
  end
end

end

    