# -*- coding: binary -*-
module RSulley

class Request #< RGraph::Node
  # This is the top-level container or super-block, instantiated with request or response.

  attr_accessor :name, :label, :stack, :block_stack, :closed_blocks, :callbacks,
                :names, :rendered, :mutant_index, :mutant, :request

  def initialize(name, &blk)
    @request        = self
    @name           = name
    @label          = name
    @stack          = []
    @block_stack    = []
    @closed_blocks  = {}
    @callbacks      = {}
    @names          = {}
    @rendered       = ''
    @mutant_index   = 0
    @mutant         = nil

    # run the provided block in the current instance
    instance_eval &blk
  end

  def mutate
    mutated = false

    @stack.each do |item|
      if item.fuzzable && item.mutate
        mutated = true
        @mutant = item unless item.is_a? RSulley::Block
        break
      end
    end
    
    @mutant_index += 1 if mutated
    mutated
  end
  
  def num_mutations
    count = 0
    
    @stack.each do |item|
      count += item.num_mutations if item.fuzzable
    end
    
    count
  end
  
  def pop
    raise "block stack out of sync" if @block_stack.empty?
    @block_stack.pop
  end
  
  def push(item)
    if item.respond_to?(:name) && item.name
      raise SyntaxError, "block name #{item.name} already exists" if @names.has_key? item.name
      @names[item.name] = item
    end
    
    if @block_stack.empty?
      @stack << item
    else
      @block_stack.last.push(item)
    end
    
    @block_stack << item if item.is_a? RSulley::Block
  end
  
  def update_size(stak, name)
    blocks = []
    stak.each do |item|
      if item.is_a? RSulley::Size
        item.render
      elsif item.is_a? RSulley::Block
        blocks << item
      end
    end
    
    blocks.each do |b|
      update_size(b.stack, b.name)
      b.render
    end
  end
  
  def render
    raise "unclosed block #{@block_stack.last.name}" unless @block_stack.empty?
    
    @stack.each { |item| item.render }
    
    @callbacks.each_pair { |k, v| v.each { |item| item.render } }
    
    @stack.each do |item|
      if item.is_a? RSulley::Block
        update_size(item.stack, item.name)
        item.render
      end
    end
    
    @rendered = @stack.each.inject('') { |result, item| result += item.rendered; result }
  end
  
  def reset
    @mutant_index  = 1
    @closed_blocks = {}
    
    @stack.each do |item|
      item.reset if item.fuzzable
    end
  end
  
  def walk(curr_stack = nil)
    curr_stack ||= @stack
    curr_stack.each do |item|
      if item.is_a? RSulley::Block
        walk(item.stack) do |item|
          yield item
        end
      else
        yield item
      end
    end
  end
  
  def block(block_name, opts = {}, &blk)
    # creates a new block under the current request or block
    opts[:dep_values]  ||= []
    opts[:dep_compare] ||= "=="
    
    raise SyntaxError, "ruby block must be provided" unless block_given?
    
    push RSulley::Block.new(block_name, self, opts)
    instance_eval &blk
    pop
  end
  
  def checksum(block_name, opts = {})
    opts[:algorithm] ||= :crc32
    opts[:length]    ||= 0
    opts[:endian]    ||= "<"
    
    if @block_stack.map { |item| item.name }.include? block_name
      raise SytaxError, "cannot add a checksum for a block currently in the stack"
    end
    
    push RSulley::Checksum.new(block_name, self, opts)
  end
  
  def repeat(block_name, opts = {})
    opts[:min_reps] = opts[:min_reps] || opts[:min] || 0
    opts[:max_reps] = opts[:max_reps] || opts[:max] || 0
    opts[:step]     ||= 1
    opts[:fuzzable] = true unless opts.has_key? :fuzzable
    
    push RSulley::Repeat.new(block_name, self, opts)
  end
  
  def size(block_name, opts = {})
    opts[:length] ||= 4
    opts[:endian] ||= "<"
    opts[:format] ||= :binary
    
    if request.block_stack.map { |item| item.name }.include? block_name
      raise SytaxError, "cannot add a size for a block currently in the stack"
    end
    
    push RSulley::Size.new(block_name, self, opts)
  end
  
  def update(block_name, value)
    raise SytaxError, "no object with #{block_name} found in current request" unless request.names.has_key? block_name
    request.names[block_name].value = value
  end
  
  def binary(value, opts = {})
    value.gsub!(/[ \t\r\n\,]|0x|\\x/,   "")
    push RSulley::Static.new(parsed.unhexify, opts)
  end
  
  def delim(value, opts = {})
    opts[:fuzzable] = true unless opts.key? :fuzzable 
    push RSulley::Delim.new(value, opts)
  end
  
  def group(group_name, *values)
    push RSulley::Group.new(group_name, values)
  end
  
  def lego(lego_type, opts = {})
    lego_name = "LEGO_%08x" % @names.count
    raise SyntaxError, "invalid lego #{lego_type}" unless "Legos::#{lego_type.to_s.camelize}".safe_constantize
    push "Legos::#{lego_type.to_s.camelize}".safe_constantize.new(lego_name, self, opts[:value], opts)
    pop
  end
  
  def random(value, opts = {})
    opts[:min_length]    = opts[:min_length] || opts[:min] || 0
    opts[:max_length]    = opts[:max_length] || opts[:max] || 255
    opts[:max_mutations] = opts[:max_mutations] || opts[:count] || opts[:num] || 25
    opts[:fuzzable] = true unless opts.key? :fuzzable
    
    push RSulley::Random.new(value, opts)
  end
  
  def static(value, opts = {})
    push RSulley::Static.new(value, opts)
  end
  
  def string(value, opts = {})
    opts[:size]     ||= -1
    opts[:padding]  ||= "\x00"
    opts[:encoding] ||= "ascii"
    opts[:max_len]  = opts[:max_len] || opts[:max] || 0
    opts[:fuzzable] = true unless opts.key? :fuzzable
    
    push RSulley::Str.new(value, opts)
  end
  
  def bit_field(value, width, opts = {})
    push RSulley::BitField.new(value, width, opts)
  end
  
  def byte(value, opts = {})
    opts[:endian] ||= "<"
    opts[:format] ||= :binary
    opts[:fuzzable] = true unless opts.key? :fuzzable
    
    push RSulley::Byte.new(value, opts)
  end
  
  def word(value, opts = {})
    opts[:endian] ||= "<"
    opts[:format] ||= :binary
    opts[:fuzzable] = true unless opts.key? :fuzzable
    
    push RSulley::Word.new(value, opts)
  end
  
  def dword(value, opts = {})
    opts[:endian] ||= "<"
    opts[:format] ||= :binary
    opts[:fuzzable] = true unless opts.key? :fuzzable
    
    push RSulley::DWord.new(value, opts)
  end
  
  def qword(value, opts = {})
    opts[:endian] ||= "<"
    opts[:format] ||= :binary
    opts[:fuzzable] = true unless opts.key? :fuzzable
    
    push RSulley::QWord.new(value, opts)
  end
  
  alias_method :dunno,   :static
  alias_method :raw,     :static
  alias_method :unknown, :static
  alias_method :bit,     :bit_field
  alias_method :bits,    :bit_field
  alias_method :char,    :byte
  alias_method :long,    :dword
  alias_method :int,     :dword
  alias_method :double,  :qword
  alias_method :repeater, :repeat
  
  def cstring(x)
    string(x)
    static("\x00")
  end
  
  def hex_dump(data, addr = 0)
    data.to_s[addr..-1].hexdump
  end
end

end
