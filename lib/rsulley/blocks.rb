# -*- coding: binary -*-
module RSulley

class Block
  attr_accessor :name, :request, :group, :encoder, :dep, :dep_value, :dep_values, :dep_compare,
                :stack, :rendered, :fuzzable, :group_idx, :fuzz_complete, :mutant_index
  
  def initialize(name, request, opts = {})
    @name         = name
    @request      = request
    @group        = opts[:group]
    @encoder      = opts[:encoder]
    @dep          = opts[:dep]
    @dep_value    = opts[:dep_value]
    @dep_values   = opts[:dep_values]  || []
    @dep_compare  = opts[:dep_compare] || "=="
    
    @stack        = []
    @rendered     = ""
    @fuzzable     = true
    @group_idx    = 0
    @fuzz_complete = false
    @mutant_index = 0
  end
  
  def mutate
    mutated = false
    return false if @fuzz_complete
    
    if @group
      
      group_count = @request.names[@group].num_mutations
      @request.names[@group].value = @request.names[@group].values[@group_idx]
      
      @stack.each do |item|
        if item.fuzzable && item.mutate
          mutated = true
          @request.mutant = item unless item.is_a? RSulley::Block
          break
        end
      end
      
      if !mutated
        @group_idx += 1
        
        if @group_idx == group_count
          @request.names[@group].value = @request.names[@group].original_value
        else
          @request.names[@group].value = @request.names[@group].values[@group_idx]
        
          @stack.each do |item|
            item.reset if item.fuzzable
          end
          
          @stack.each do |item|
            if item.fuzzable && item.mutate
              mutated = true
              @request.mutant = item unless item.is_a? RSulley::Block
              break
            end
          end
        end
      end
      
    else
     
      @stack.each do |item|
        if item.fuzzable && item.mutate
          mutated = true
          @request.mutant = item unless item.is_a? RSulley::Block
          break
        end
      end
    
    end
    
    if mutated && @dep
      if @dep_values
        @request.names[@dep].value = @dep_values.first
      else
        @request.names[@dep].value = @dep_value
      end
    end
    
    if !mutated
      @fuzz_complete = true
      @request.names[@dep].value = @request.names[@dep].original_value if @dep
    end
    
    mutated
  end
  
  def num_mutations
    count = 0
    
    @stack.each do |item|
      count += item.num_mutations if item.fuzzable
    end
    
    count *= @request.names[@group].values.count if @group
    count
  end
  
  def push(item)
    @stack << item
  end
  
  def render
    @request.closed_blocks[@name] = self
    
    if @dep
      
      case @dep_compare
      when "=="
        if !@dep_values.empty? && !@dep_values.include?(@request.names[@dep].value)
          return @rendered = ""
        
        elsif @dep_values.empty? && @request.names[@dep].value != @dep_value
          return @rendered = ""
        end
      
      when "!="
        if !@dep_values.empty? && @dep_values.include?(@request.names[@dep].value)
          return @rendered = ""
        
        elsif @request.names[@dep].value != @dep_value
          return @rendered = ""
        end
      
      when ">"
        if @dep_value <= @request.names[@dep].value
          return @rendered = ""
        end
      
      when ">="
        if @dep_value < @request.names[@dep].value
          return @rendered = ""
        end
      
      when "<"
        if @dep_value >= @request.names[@dep].value
          return @rendered = ""
        end
        
      when "<="
        if @dep_value > @request.names[@dep].value
          return @rendered = ""
        end
      end
      
    end
    
    @stack.each do |item|
      item.render
    end
    
    @rendered = ""
    @stack.each do |item|
      @rendered += item.rendered.to_s
    end
    
    @rendered = @encoder.call(@rendered) if @encoder
    
    if @request.callbacks[@name]
      @request.callbacks[@name].each do |item|
        item.render
      end
    end
    @rendered
  end
  
  def reset
    @fuzz_complete = false
    @group_idx     = 0
  
    @stack.each do |item|
      item.reset if item.fuzzable
    end
  end
  
end

class Checksum
  attr_accessor :block_name, :request, :algorithm, :length, :endian, :name,
                :rendered, :fuzzable, :hash_key
  
  def initialize(block_name, request, opts = {})
    checksum_lengths = { crc32: 4, adler32: 4, md5: 16, sha1: 20 }
    
    @block_name = block_name
    @request    = request
    @algorithm  = opts[:algorithm] || :crc32
    @length     = checksum_lengths[@algorithm] || opts[:length] || 0
    @endian     = opts[:endian]    || "<"
    @name       = opts[:name]
    @hash_key   = opts[:hash_key]
    
    @rendered   = ""
    @fuzzable   = false
  end
  
  def checksum(data)
    case @algorithm
    when Proc
      return @algorithm.call(data)
    when String
      @algorithm = @algorithm.to_sym
    when Symbol
      # do nothing
    else
      raise SyntaxError, "algorithm must be a string, symbol, or lambda"
    end
    
    case @algorithm
    when :crc32
      return [Zlib.crc32(data)].pack("L#{@endian}")
      
    when :adler32
      return [Zlib.adler32(data)].pack("L#{@endian}")
      
    when :md5
      return Digest::MD5.digest(data)
      
    when :sha1
      return Digest::SHA1.digest(data)
      
    when :sha256
      return Digest::SHA256.digest(data)
      
    when :sha512
      return Digest::SHA512.digest(data)
      
    when :md5_hmac
      return Digest::HMAC.digest(data, @hash_key, Digest::MD5)
      
    when :sha1_hmac
      return Digest::HMAC.digest(data, @hash_key, Digest::SHA1)
      
    when :sha256_hmac
      return Digest::HMAC.digest(data, @hash_key, Digest::SHA256)
      
    when :sha512_hmac
      return Digest::HMAC.digest(data, @hash_key, Digest::SHA512)
      
    when :fgd_wf
      crcpoly_le = 0xedb88320; crc = 0
      data.each_byte do |b|
        crc ^= b
        0.upto(7) do |i|
          multiplier = ((crc & 0x1) != 0 ? crcpoly_le : 0)
          crc = (crc >> 1) ^ multiplier
        end
      end
      return [crc].pack("L#{@endian}")
      
    end
    
    raise SyntaxError, "invalid checksum algorithm #{@algorithm}"
  end
  
  def render
    @rendered = ""
    
    if @request.closed_blocks[@block_name]
      block_data  = @request.closed_blocks[@block_name].rendered
      @rendered   = checksum(block_data)
    else
      @request.callbacks[@block_name] ||= []
      @request.callbacks[@block_name] << self
    end
    
    @rendered
  end
  
end


class Repeat
  attr_accessor :block_name, :request, :min_reps, :max_reps, :step, :variable, :fuzzable, :name, :rendered
  
  def initialize(block_name, request, opts = {})
    @block_name = block_name
    @request    = request
    @variable   = opts[:variable]
    @min_reps   = opts[:min_reps] || 0
    @max_reps   = opts[:max_reps] || 0
    @step       = opts[:step]     || 1
    @name       = opts[:name]
    @fuzzable   = opts.key?(:fuzzable) ? opts[:fuzzable] : true
    
    @value          = ""
    @original_value = ""
    @rendered       = ""
    @fuzz_complete  = false
    @fuzz_library   = []
    @mutant_index   = 0
    @current_reps   = min_reps
    
    unless @request.names[@block_name]
      raise SyntaxError, "cannot add repeater for non-existant block #{@block_name}"
    end
    
    if @variable.nil? && @max_reps.nil?
      raise SyntaxError, "repeater for block #{@block_name} does not have min/max variable binding"
    end
    
    if @variable && !@variable.is_a?(BitField)
      raise SyntaxError, "attempt to bind repeater for block #{@block_name} to non-int primitive #{@variable.inpect}"
    end
    
    if !@variable
      @fuzz_library = (@min_reps..@max_reps).step(@step).map { |i| i } 
    else
      @fuzzable = false
    end
  end
  
  def mutate
    @request.names[@block_name].render
    
    unless @request.closed_blocks[@block_name]
      raise SyntaxError, "cannot apply repeater to unclosed block"
    end
    
    @fuzz_complete = true if @mutant_index == num_mutations
    
    if !@fuzzable || @fuzz_complete
      @value = @original_value
      @current_reps = @min_reps
      return false
    end
    
    if @variable
      @current_reps = @variable.value
    else
      @current_reps = @fuzz_library[@mutant_index]
    end
    
    block = @request.closed_blocks[@block_name]
    @value = block.rendered * @fuzz_library[@mutant_index]
    
    @mutant_index += 1
    return true
  end
  
  def num_mutations
    @fuzz_library.count
  end
  
  def render
    unless @request.closed_blocks[@block_name]
      raise SyntaxError, "cannot apply repeater to unclosed block #{block_name}"
    end
    
    if @variable
      block = @request.closed_blocks[@block_name]
      @value = block.rendered * @variable.value
    end
    
    @rendered = @value
  end
  
  def reset
    @fuzz_complete = false
    @mutant_index  = 0
    @value         = @original_value
  end

end


class Size
  attr_accessor :block_name, :request, :length, :endian, :format, :inclusive, :signed,
                :math, :fuzzable, :name, :rendered
  
  def initialize(block_name, request, opts = {})
    @block_name = block_name
    @request    = request
    @length     = opts[:length] || 4
    @endian     = opts[:endian] || "<"
    @format     = opts[:format] || :binary
    @inclusive  = opts[:inclusive]
    @signed     = opts[:signed]
    @math       = opts[:math]   || lambda { |x| x }
    @fuzzable   = opts[:fuzzable]
    @name       = opts[:name]
    
    @original_value = "N/A"
    @type           = :size
    @bit_field      = BitField.new(0, @length*8, endian: @endian, format: @format, signed: @signed)
    @rendered       = ""
    @fuzz_complete  = @bit_field.fuzz_complete
    @fuzz_library   = @bit_field.fuzz_library
    @mutant_index   = @bit_field.mutant_index
    @value          = @bit_field.value
  end
  
  def exhaust
    num = num_mutations - @mutant_index
    
    @fuzz_complete           = true
    @mutant_index            = num_mutations
    @bit_field.mutant_index  = num_mutations
    @value                   = @original_value
    
    num
  end
  
  def mutate
    @fuzz_complete = true if @mutant_index == num_mutations
    @mutant_index += 1
    @bit_field.mutate
  end
  
  def num_mutations
    @bit_field.num_mutations
  end
  
  def render
    @rendered = ""
    
    if @fuzzable && @bit_field.mutant_index > 0 && !@bit_field.fuzz_complete
      @rendered = @bit_field.render
    
    elsif @request.closed_blocks[@block_name]
      block            = @request.closed_blocks[@block_name]
      @bit_field.value = @math.call(block.rendered.length + (@inclusive ? @length : 0))
      @rendered        = @bit_field.render
    
    else
      @request.callbacks[@block_name] ||= []
      @request.callbacks[@block_name] << self
    end
    
    @rendered
  end
  
  def reset
    @bit_field.reset
  end

end

end