#!/usr/bin/env ruby

request_closed = true
indent         = 0

File.read(ARGV[0]).each_line do |line|
  case line
  when /s.connect\((.+)\)$/
    params = $1.dup
    puts "connect " + params.scan(/\"[a-z0-9]+\"/i).map { |p| ":#{p.downcase.gsub(' ', '_').gsub('"', '')}" }.join(', ')
    
  when /###########################################################################################/
    if !request_closed
      indent -= 1
      puts "end"
      puts
      request_closed = true
    end
    puts line
  when /s_initialize\(\"([^\)]*)\"\)/
    if !request_closed
      indent -= 1
      puts "end"
      puts
    end
    puts "request :#{$1.downcase.gsub(' ', '_')} do"
    request_closed = false
    indent += 1
  when /s_block_start\(([^\)]*)\)/
    puts "#{'  ' * indent}block :#{$1.downcase.sub(' ', '_')} do"
    indent += 1
  when /s_block_end/
    indent -= 1
    puts "#{'  ' * indent}end"
  when /s_([a-z]+)\((.*)/
    prim   = $1.dup
    params = $2[0..-2].split(',')
    params.map! do |p|
      p = p.strip
      if p =~ /[a-z]+=[a-z\"\"]+/i && p != "="
        p = ":" + p.gsub('"', '').split('=').join(' => :')
      else
        p
      end
    end
    
    puts "#{'  ' * indent}#{"%-6s" % prim} #{params.join(', ')}"
  else
    puts line
  end
end

puts "end"
puts
 