# coding: binary

module RSulley

class Primitive
  attr_accessor :fuzz_complete, :fuzz_library, :fuzzable, :mutant_index, :original_value, :rendered,
                :value, :type, :name
  
  def initialize
    @fuzz_complete  = false
    @fuzz_library   = []
    @fuzzable       = true
    @mutant_index   = 0
    @original_value = nil
    @rendered       = ""
    @value          = nil
  end
  
  def exhaust
    num = num_mutations - @mutant_index
    
    @fuzz_complete = true
    @mutant_index  = num_mutations
    @value         = @original_value
    
    num
  end
  
  def mutate
    @fuzz_complete = true if @mutant_index == num_mutations
    
    if !@fuzzable || @fuzz_complete
      @value = @original_value
      return false
    end
    
    @value = @fuzz_library[@mutant_index]
    
    @mutant_index += 1
    return true
  end
  
  def num_mutations
    @fuzz_library.count
  end
  
  def render
    @rendered = @value
  end
  
  def reset
    @fuzz_complete = false
    @mutant_index  = 0
    @value         = @original_value
  end
end


class Delim < Primitive
  attr_accessor :fuzz_complete, :fuzz_library, :fuzzable, :mutant_index, :original_value, :rendered,
                :value, :type, :name
                
  def initialize(value, opts = {})
    @value          = value
    @original_value = value
    @fuzzable       = opts[:fuzzable]
    @name           = opts[:name]
    
    @type           = :delim
    @rendered       = ""
    @fuzz_complete  = false
    @fuzz_library   = []
    @mutant_index   = 0
    
    [2, 5, 41, 101, 257, 401, 513, 1025, 4097].each { |c| @fuzz_library << @value * c } if @value
    
    @fuzz_library << ""
    
    [1, 2, 41, 101, 257, 401, 513, 1025, 4097].each { |c| @fuzz_library << "\t" * c } if @value == " "
    
    @fuzz_library << " "
    @fuzz_library << "\t"
    @fuzz_library << "\t " * 100
    @fuzz_library << "\t\r\n" * 100
    @fuzz_library << "!"
    @fuzz_library << "@"
    @fuzz_library << "#"
    @fuzz_library << "$"
    @fuzz_library << "%"
    @fuzz_library << "^"
    @fuzz_library << "&"
    @fuzz_library << "*"
    @fuzz_library << "("
    @fuzz_library << ")"
    @fuzz_library << "-"
    @fuzz_library << "_"
    @fuzz_library << "+"
    @fuzz_library << "="
    @fuzz_library << ":"
    @fuzz_library << ": " * 100
    @fuzz_library << ":7" * 100
    @fuzz_library << ";"
    @fuzz_library << "'"
    @fuzz_library << "\""
    @fuzz_library << "/"
    @fuzz_library << "\\"
    @fuzz_library << "?"
    @fuzz_library << "<"
    @fuzz_library << ">"
    @fuzz_library << "."
    @fuzz_library << ","
    @fuzz_library << "\r"
    @fuzz_library << "\n"
    @fuzz_library << "\r\n" * 64
    @fuzz_library << "\r\n" * 128
    @fuzz_library << "\r\n" * 512
  end
end
      
class Group < Primitive
  attr_accessor :fuzz_complete, :fuzz_library, :fuzzable, :mutant_index, :original_value, :rendered,
                :value, :type, :name, :values
  
  def initialize(name, values, opts = {})
    @name           = name
    @values         = values
    @fuzzable       = true
    
    @type           = :group
    @value          = @values.first
    @original_value = @values.first
    @rendered       = ""
    @fuzz_complete  = false
    @mutant_index   = 0
    
    unless @values.empty?
      @values.each do |val|
        raise SyntaxError, "value list may only contain strings and raw data" unless val.is_a? String
      end
    end
  end
  
  def mutate
    @fuzz_complete = true if @mutant_index == num_mutations
    
    if !@fuzzable || @fuzz_complete
      @value = @values.first
      return false
    end
    
    @value = @values[@mutant_index]
    @mutant_index += 1
    true
  end
  
  def num_mutations
    @values.count
  end
end


class Random < Primitive
  attr_accessor :fuzz_complete, :fuzz_library, :fuzzable, :mutant_index, :original_value, :rendered,
                :value, :type, :name, :min_length, :max_length, :max_mutations, :step
  
  def initialize(value, opts = {})
    @value          = value.to_s
    @original_value = value.to_s
    @min_length     = opts[:min_length]    || 1
    @max_length     = opts[:max_length]    || 1
    @max_mutations  = opts[:max_mutations] || 25
    @step           = opts[:step]
    @name           = opts[:name]
    @fuzzable       = opts.key?(:fuzzable) ? opts[:fuzzable] : true
    
    @type           = :random
    @rendered       = ""
    @fuzz_complete  = false
    @mutant_index   = 0
    
    @max_mutations = (@max_length - @min_length) / @step + 1 if @step
  end

  def mutate
    @fuzz_complete = true if @mutant_index == num_mutations
    
    if !@fuzzable || @fuzz_complete
      @value = @original_value
      return false
    end
    
    if @step
      @length = @min_length + @mutant_index * @step
    else
      @length = rand(@max_length - @min_length + 1) + @min_length
    end
    
    @value = @length.times.inject("") { |r| r += rand(256).chr }
    
    @mutant_index += 1
    
    true
  end
  
  def num_mutations
    @max_mutations
  end
end


class Calc < Primitive
  attr_accessor :fuzz_complete, :fuzz_library, :fuzzable, :mutant_index, :original_value, :rendered,
                :value, :type, :name
                
  def initialize(value, opts = {})
    @value          = value
    @original_value = value
    @fuzzable       = false
    @mutant_index   = 0
    @type           = :calc
    @rendered       = ""
    @fuzz_complete  = true
  end
  
  def mutate
    false
  end

  def num_mutations
    0
  end
  
  def render
    @rendered = @value.call
  end
end


class Static < Primitive
  attr_accessor :fuzz_complete, :fuzz_library, :fuzzable, :mutant_index, :original_value, :rendered,
                :value, :type, :name
                
  def initialize(value, opts = {})
    @value          = value
    @original_value = value
    @fuzzable       = false
    @mutant_index   = 0
    @type           = :static
    @rendered       = ""
    @fuzz_complete  = true
  end
  
  def mutate
    false
  end

  def num_mutations
    0
  end
end


class Str < Primitive
  attr_accessor :fuzz_complete, :fuzzable, :mutant_index, :original_value, :rendered,
                :value, :type, :name, :padding, :encoding, :this_library, :size
  
  def initialize(value, opts = {})
    @value          = value
    @original_value = value
    @size           = opts[:size]     || -1
    @padding        = opts[:padding]  || "\x00"
    @encoding       = opts[:encoding] || 'ascii'
    @name           = opts[:name]
    @fuzzable       = opts.key?(:fuzzable) ? opts[:fuzzable] : true

    @type           = :string
    @rendered       = ""
    @fuzz_complete  = false
    @mutant_index   = 0
    
    @this_library   = [
      @value * 2,
      @value * 10,
      @value * 100,
      @value * 2 + "\xfe",
      @value * 10 + "\xfe",
      @value * 100 + "\xfe",
    ]
    
    @@fuzz_library ||= build_library
    
    if opts[:max_len] && opts[:max_len] > 0
      @this_library  = @this_library.map  { |s| s.length > opts[:max_len] ? nil : s }.compact
      @@fuzz_library = @@fuzz_library.map { |s| s.length > opts[:max_len] ? nil : s }.compact
    end
  end
  
  def mutate
    loop do
      @fuzz_complete = true if @mutant_index == num_mutations
      
      if !@fuzzable || @fuzz_complete
        @value = @original_value
        return false
      end
      
      @value = (@@fuzz_library + @this_library)[@mutant_index]
      
      @mutant_index += 1
      break if @size == -1
      next if @value.length > @size
      
      if @value.length < @size
        @value = @value + @padding * (@size - @value.length)
        break
      end
    end
    
    true
  end
  
  def num_mutations
    @@fuzz_library.count + @this_library.count
  end
  
  def render
    @rendered = @value.to_s.encode(@encoding) rescue @value.to_s
  end
  
  def fuzz_library
    @@fuzz_library
  end
  
  def build_library
    lib = [
      # omission.
      "",

      # strings ripped from spike (and some others I added)
      "/.:/"  + "A"*5000 + "\x00\x00",
      "/.../" + "A"*5000 + "\x00\x00",
      "/.../.../.../.../.../.../.../.../.../.../",
      "/../../../../../../../../../../../../etc/passwd",
      "/../../../../../../../../../../../../boot.ini",
      "..:..:..:..:..:..:..:..:..:..:..:..:..:",
      "\\\\*",
      "\\\\?\\",
      "/\\" * 5000,
      "/." * 5000,
      "!@#$\%\%^#$\%#$@#$\%$$@#$\%^^**(()",
      "%01%02%03%04%0a%0d%0aADSF",
      "%01%02%03@%04%0a%0d%0aADSF",
      "/%00/",
      "%00/",
      "%00",
      "%u0000",
      "%\xfe\xf0%\x00\xff",
      "%\xfe\xf0%\x01\xff" * 20,

      # format strings.
      "%s%n",
      "%s%n%s%n%s%n",
      "%n"     * 100,
      "%n"     * 500,
      "\"%n\"" * 500,
      "%s"     * 100,
      "%s"     * 500,
      "\"%s\"" * 500,

      # command injection.
      "|touch /tmp/SULLEY",
      ";touch /tmp/SULLEY;",
      "|notepad",
      ";notepad;",
      "\nnotepad\n",

      # SQL injection.
      "1;SELECT%20*",
      "'sqlattempt1",
      "(sqlattempt2)",
      "OR%201=1",

      # some binary strings.
      "\xde\xad\xbe\xef",
      "\xde\xad\xbe\xef" * 10,
      "\xde\xad\xbe\xef" * 100,
      "\xde\xad\xbe\xef" * 1000,
      "\xde\xad\xbe\xef" * 10000,
      "\x00"             * 1000,

      # miscellaneous.
      "\r\n" * 100,
      "<>" * 500,         # sendmail crackaddr (http://lsd-pl.net/other/sendmail.txt)
    ]
    
    str_counts = [
      16, 32, 64, 128, 255, 256, 257, 511, 512, 513, 1023, 1024, 2048, 2049, 4095, 4096, 4097, 5000, 10000, 20000,
      32762, 32763, 32764, 32765, 32766, 32767, 32768, 32769, 0xFFFF-2, 0xFFFF-1, 0xFFFF#, 0xFFFF+1,
      #0xFFFF+2, 99999, 100000, 500000, 1000000
    ]
    
    chars = [
      "A", "B", "1", "2", "3", "<", ">", "'", "\"", "/", "\\", "?", "=", "a=", "&", ".", ",", "(", ")",
      "[", "]", "%", "*", "-", "+", "{", "}", "\x14", "\xFE", "\xFF"
    ]
    
    chars.each do |c|
      str_counts.each do |n|
        lib << c * n
      end
    end
    
    [128, 256, 1024, 2048, 4096, 32767, 0xFFFF].each do |len|
      s = "B" * len
      s = s[0..s.length/2-1] + "\x00" + s[s.length/2..-1]
      lib << s
    end
    
    begin
      File.read(".fuzz_strings").each_line do |line|
        line.chomp!
        lib << line unless line.empty?
      end
    rescue
    end
    
    lib
  end
end


class BitField < Primitive
  attr_accessor :fuzz_complete, :fuzz_library, :fuzzable, :mutant_index, :original_value, :rendered,
                :value, :type, :name, :width, :max_num, :endian, :format, :signed, :full_range
  
  def initialize(value, width, opts = {})
    raise SyntaxError, "value must be numeric" unless value.is_a? Numeric
    raise SyntaxError, "width must be numeric" unless width.is_a? Numeric
    
    opts[:endian] = '<' if opts[:endian] && opts[:endian].to_sym == :little
    opts[:endian] = '>' if opts[:endian] && opts[:endian].to_sym == :big
    
    @value          = value
    @original_value = value
    @width          = width
    @max_num        = opts[:max_num]
    @endian         = opts[:endian] || "<"
    @format         = opts[:format] || :binary
    @signed         = opts[:signed]
    @full_range     = opts[:fuzz_range]
    @fuzzable       = opts.key?(:fuzzable) ? opts[:fuzzable] : true
    @name           = opts[:name]
    
    @rendered       = ""
    @fuzz_complete  = false
    @fuzz_library   = []
    @mutant_index   = 0
    
    @max_num = to_decimal('1' * @width) unless @max_num
    
    raise SyntaxError, "max_num must be numeric" unless @max_num.is_a? Numeric
    
    if @full_range
      (0..@max_num).each { |i| @fuzz_library << i }
    else
      add_integer_boundaries(0)
      [2, 3, 4, 8, 16, 32].each { |i| add_integer_boundaries(@max_num / i) }
      add_integer_boundaries(@max_num)
    end
    
    begin
      File.read(opts[:fuzz_ints] || ".fuzz_ints").each_line do |line|
        line.chomp!
        @fuzz_library << line.to_i unless line.empty? || line.to_i > @max_num
      end
    rescue
    end
  end
  
  def add_integer_boundaries(integer)
    (-10..10).each do |i|
      val = integer + i
      
      if val > 0 && val <= @max_num
        @fuzz_library << val unless @fuzz_library.include?(val)
      end
    end
  end
  
  def render
    if @format.to_sym == :binary
      bit_stream = @width % 8 == 0 ? to_binary : "0" * (8 - (@width % 8)) + to_binary
      @rendered = [bit_stream].pack("B*")
      @rendered.reverse! if @endian == "<"
    else
      if @signed && to_binary[0] == "1"
        @max_num  = to_decimal("0" + "1" * (@width - 1))
        val       = @value & @max_num
        val       = @max_num - val
        @rendered = "%d" % ~val
      else
        @rendered = "%d" % @value
      end
    end
    @rendered
  end
  
  def to_binary(opts = {})
    number    = opts[:number]    || @value
    bit_count = opts[:bit_count] || @width
    
    number.to_s(2).ralign(bit_count, '0')
  end
  
  def to_decimal(binary)
    binary.to_i(2)
  end
end


class Byte < BitField            
  def initialize(value, opts = {})
    @type = :byte
    value = value.to_s.unpack("C").first unless value.is_a? Numeric
    super(value, 8, opts)
  end
end


class Word < BitField            
  def initialize(value, opts = {})
    @type = :word
    value = value.to_s.unpack("S#{opts[:endian]}").first unless value.is_a? Numeric
    super(value, 16, opts)
  end
end


class DWord < BitField             
  def initialize(value, opts = {})
    @type = :dword
    value = value.to_s.unpack("L#{opts[:endian]}").first unless value.is_a? Numeric
    super(value, 32, opts)
  end
end


class QWord < BitField          
  def initialize(value, opts = {})
    @type = :qword
    value = value.to_s.unpack("Q#{opts[:endian]}").first unless value.is_a? Numeric
    super(value, 64, opts)
  end
end

end
