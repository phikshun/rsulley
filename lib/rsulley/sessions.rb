module RSulley

class Target
  attr_accessor :monitor, :monitor_options, :transport, :transport_options, 
                :vmcontrol, :vmcontrol_options
                
  def initialize(opts = {})    
    @monitor   = nil
    @transport = nil
    @vmcontrol = nil
    
    @monitor_options   = { :logger => opts[:logger] }
    @transport_options = { :logger => opts[:logger] }
    @vmcontrol_options = { :logger => opts[:logger] }
    
    configure(opts)
  end
  
  def configure(opts = {})
    if opts.key? :monitor
      if opts[:monitor][:type]
        @monitor = opts[:monitor][:type]
        @monitor_options.merge! opts[:monitor]
      end
    end
    
    if opts.key? :transport
      if opts[:transport][:type]
        @transport = opts[:transport][:type]
        @transport_options.merge! opts[:transport]
      end
    end
    
    if opts.key? :vmcontrol
      if opts[:vmcontrol][:type]
        @vmcontrol = opts[:vmcontrol][:type]
        @vmcontrol_options.merge! opts[:vmcontrol]
      end
    end
  end
  
  def start
    if @transport
      if @transport.is_a?(Symbol) || @transport.is_a?(String)
        @transport = "#{@transport.to_s.camelize}Transport".safe_constantize.new(@transport_options)
      elsif @transport.class == Class
        @transport = @transport.new(@transport_options)
      end
    else
      raise SyntaxError, "transport must be provided"
    end
    
    if @monitor
      if @monitor.is_a?(Symbol) || @monitor.is_a?(String)
        @monitor = "#{@monitor.to_s.camelize}Monitor".safe_constantize.new(@monitor_options)
      elsif @monitor.class == Class
        @monitor = @monitor.new(@monitor_options)
      end
    end
    
    if @vmcontrol
      if @vmcontrol.is_a?(Symbol) || @vmcontrol.is_a?(String)
        @vmcontrol = "#{@vmcontrol.to_s.camelize}Control".safe_constantize.new(@vmcontrol_options)
      elsif @vmcontrol.class == Class
        @vmcontrol = @vmcontrol.new(@vmcontrol_options)
      end
    end
  end
end

class Connection < RSulley::Edge
  attr_accessor :src, :dst, :callback
  
  def initialize(src, dst, opts = {})
    super(src, dst)
    @callback = opts[:callback]
  end
end

class Session < RSulley::Graph
  attr_accessor :logger
  
  def initialize(opts = {})
    super(nil)
    
    @session_filename   = opts[:session_filename]
    @skip               = opts[:skip]               || 0
    @sleep_time         = opts[:sleep_time]
    @restart_interval   = opts[:restart_interval]
    @timeout            = opts[:timeout]            || 5.0
    @crash_threshold    = opts[:crash_threshold]    || 3
    @restart_sleep_time = opts[:restart_sleep_time] || 300
    
    Logging.color_scheme('bright',
      :levels => {
        :info  => :green,
        :warn  => :yellow,
        :error => :red,
        :fatal => [:white, :on_red]
      },
      #:date => :blue,
      :logger => :cyan,
      #:message => :magenta
    )
    
    Logging.appenders.stdout(
      'stdout',
      :level  => :debug,
      :layout => Logging.layouts.pattern(
        :pattern => '[%d] [%-5l] -> %m\n',
        :color_scheme => 'bright'
      )
    )
    
    @logger = Logging.logger['rsulley_logger']
    @logger.level = :debug
    @logger.add_appenders 'stdout'
    
    if opts[:logfile]
       Logging.appenders.file(
         'file',
         :filename => opts[:logfile],
         :level    => opts[:logfile_level] || :debug,
         :layout   => Logging.layouts.pattern(
           :pattern => '[%d] [%-5l] -> %m\n',
         )
       )
       @logger.add_appenders 'file'
    end
    
    @total_num_mutations = 0
    @total_mutant_index  = 0
    @fuzz_node           = nil
    @targets             = []
    @monitor_results     = {}
    @pause_flag          = false
    @crashing_primitives = {}
    
    import_file
    
    @root       = RSulley::Node.new
    @root.label = "__ROOT_NODE__"
    @last_recv  = nil
    
    add_node(@root)
  end
  
  def target(opts = {})
    add_target RSulley::Target.new(opts.merge :logger => @logger)
  end
  
  def add_node(node)
    node.number = @nodes.count
    node.id     = @nodes.count
    
    @nodes[node.id] = node
    self
  end
  
  def add_target(target)
    target.start
    @targets << target
  end
  
  def connect(src, dst = nil, opts = {})
    unless dst
      dst = src
      src = @root
    end
    
    src = find_node :name, src if src.is_a?(String) || src.is_a?(Symbol)
    dst = find_node :name, dst if dst.is_a?(String) || dst.is_a?(Symbol)
    
    add_node(src) unless src == @root || find_node(:name, src.name)
    add_node(dst) unless find_node(:name, dst.name)
    
    edge = Connection.new(src.id, dst.id, opts)
    add_edge edge
    edge
  end
  
  def export_file
    return unless @session_filename
    
    data = {}
    data["session_filename"]    = @session_filename
    data["skip"]                = @total_mutant_index
    data["sleep_time"]          = @sleep_time
    data["restart_sleep_time"]  = @restart_sleep_time
    data["restart_interval"]    = @restart_interval
    data["timeout"]             = @timeout
    data["crash_threshold"]     = @crash_threshold
    data["total_num_mutations"] = @total_num_mutations
    data["total_mutant_index"]  = @total_mutant_index
    data["monitor_results"]     = @monitor_results
    data["pause_flag"]          = @pause_flag
    
    File.open(@session_filename, 'wb') do |f|
      f.write Zlib.deflate(YAML.dump(data))
    end
  end
  
  def import_file
    f = File.open(@session_filename, 'rb')
    data = YAML.load(Zlib.inflate(f.read))
    f.close
    
    @skip                = data["total_mutant_index"]
    @session_filename    = data["session_filename"]
    @sleep_time          = data["sleep_time"]
    @restart_sleep_time  = data["restart_sleep_time"]
    @restart_interval    = data["restart_interval"]
    @timeout             = data["timeout"]
    @crash_threshold     = data["crash_threshold"]
    @total_num_mutations = data["total_num_mutations"]
    @total_mutant_index  = data["total_mutant_index"]
    @monitor_results     = data["monitor_results"]
    @pause_flag          = data["pause_flag"]
  rescue => e
    logger.error "could not load import file: #{e.message}"
  end
  
  def fuzz(opts = {})
    this_node = opts[:node] || opts[:this_node]
    path      = opts[:path] || []
    target    = nil
    
    if !this_node
      raise SyntaxError, "no targets specified"  if @targets.nil? || @targets.empty?
      raise SyntaxError, "no requests specified" unless edges_from(@root.id)
      
      this_node = @root
      @total_mutant_index  = 0
      @total_num_mutations = num_mutations
    end
    
    target = @targets.first
    
    edges_from(this_node.id).each do |edge|
      @fuzz_node    = @nodes[edge.dst]
      num_mutations = @fuzz_node.num_mutations
      
      path << edge
      
      current_path  = path[1..-1].map { |e| @nodes[e.src].name }.join(' -> ') || ''
      current_path += " -> #{@fuzz_node.name}"
      
      logger.info "current fuzz path: #{current_path}"
      logger.info "fuzzed #{@total_mutant_index} of #{@total_num_mutations} total cases"
      
      done_with_fuzz_node = false
      crash_count         = 0
      
      while !done_with_fuzz_node
        pause
        
        if !@fuzz_node.mutate
          logger.info "all possible mutations for current fuzz node exhausted"
          done_with_fuzz_node = true
          next
        end
        
        @total_mutant_index += 1
        
        if @restart_interval && @total_mutant_index % @restart_interval == 0
          logger.warn "restart interval of #{@restart_interval} reached"
          target.vmcontrol.restart if target.vmcontrol
        end
        
        if @total_mutant_index > @skip
          logger.info "fuzzing #{@fuzz_node.mutant_index} of #{num_mutations}"
          
          loop do
            target.monitor.start(@total_mutant_index) if target.monitor
            
            if !target.transport.open
              logger.error "failed to open transport"
              next
            end
            
            begin
              pre_send(target.transport)
            rescue => e
              logger.error "pre_send failed: #{e.message}"
              target.transport.close
              next
            end
            
            begin
              path[0..-2].each do |e|
                node = @nodes[e.dst]
                transmit(node, e, target)
              end
            rescue => e
              logger.error "failed transmitting a node up the path: #{e.message}"
              target.transport.close
              next
            end
            
            begin
              transmit(@fuzz_node, edge, target)
            rescue => e
              logger.error "failed transmitting a node up the path: #{e.message}"
              target.transport.close
              next
            end
            
            break
          end
          
          begin
            post_send(target.transport)
          rescue => e
            logger.error "post_send failed: #{e.message}"
            target.transport.close
            next
          end
          
          target.transport.close
          check target
          
          if @sleep_time
            logger.warn "sleeping for %.02f seconds" % @sleep_time
            sleep @sleep_time
          end
          
          export_file
        end
      end
      
      fuzz :node => @fuzz_node, :path => path
    end
    
    path.pop if path        
  end

  def num_mutations(opts = {})
    this_node = opts[:node] || opts[:this_node]
    path      = opts[:path] || []
    
    if !this_node
      this_node = @root
      @total_num_mutatations = 0
    end
    
    edges_from(this_node.id).each do |edge|
      next_node             = @nodes[edge.dst]
      @total_num_mutations += next_node.num_mutations
      
      path << edge if edge.src != @root.id
      num_mutations :node => next_node, :path => path
    end
    
    path.pop if path
    @total_num_mutations
  end
  
  def pause
    loop { @pause_flag ? sleep(1) : break }
  end
  
  def check(target)
    return unless target.monitor
    target.monitor.finish
    
    if target.monitor.check
      logger.info "monitor detected issue on test case ##{@total_mutant_index}"
      
      @crashing_primitives[@fuzz_node.mutant] ||= 0
      @crashing_primitives[@fuzz_node.mutant]  += 1
      
      if @fuzz_node.mutant.name
        msg = "primitive name: #{@fuzz_node.mutant.name}, "
      else
        msg = "primitive has no name, "
      end
      
      msg += "type: #{@fuzz_node.mutant.type}, default value: #{@fuzz_node.mutant.original_value}"
      logger.info msg
      
      @monitor_results[@total_mutant_index] = target.monitor.crash_synopsis
      logger.info @monitor_results[@total_mutant_index]
      
      if @crashing_primitives[@fuzz_node.mutant] >= @crash_threshold
        unless @fuzz_node.mutant.is_a?(Repeat) || @fuzz_node.mutant.is_a?(Group)
          skipped = @fuzz_node.mutant.exhaust
          logger.warn "crash threshold reached for this primitive, exhausting #{skipped} mutants"
          @total_mutant_index     += skipped
          @fuzz_node.mutant_index += skipped
        end
      end
      
      if target.vmcontrol && !target.vmcontrol.restart
        logger.fatal "restarting the target failed, exiting"
        export_file
        exit
      end
    end
  end
  
  def post_send(transport)
  end
  
  def pre_send(transport)
  end
  
  def transmit(node, edge, target)
    data = nil
    
    if edge.callback
      data = edge.callback.call(node, edge, target.transport)
    end
    
    logger.info "xmitting: [#{node.id}.#{@total_mutant_index}]"
    data = node.render unless data
    
    begin
      target.transport.write(data)
      logger.debug "sent #{data.to_s.length} bytes:\n#{data.to_s.hexdump}"
      @last_recv = target.transport.read
    rescue => e
      logger.error "transport error: #{e.message}"
      logger.debug "backtrace:\n#{e.backtrace}"
      @last_recv = ''
    end
    
    if @last_recv.length > 0
      logger.debug "recevied #{@last_recv.length} bytes:\n#{@last_recv.hexdump}"
    else
      logger.warn "no response received"
    end
  end
end

end 
