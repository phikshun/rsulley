# -*- coding: binary -*-
$:.unshift(File.expand_path(File.dirname(__FILE__)))

require 'rbkb'
require 'active_support/inflector'
require 'zlib'
require 'digest'
require 'logging'
require 'socket'
require 'net/telnet'

require 'rgraph/graph'
require 'rgraph/cluster'
require 'rgraph/edge'
require 'rgraph/node'

require 'blocks'
require 'request'
require 'primitives'
require 'transport'
require 'monitor'
require 'vmcontrol'
require 'sessions'

module RSulley
  # This module implements some of the code found in Sulley's main __init__.py.  Block management functions
  # have been moved to the Request object to support ruby block-based request construction

BIG_ENDIAN      = ">"
LITTLE_ENDIAN   = "<"

def get(name = nil)
  return @sulley_current unless name
  switch(name)
end

def request(name, &block)
  # Initialize a new block request.  All blocks/primitives generated with the block will apply
  # to the object generated.  Note that this behaviour is different than Sulley.  There are very
  # good reasons for that.
  
  @sulley_requests ||= {}
  @sulley_current  ||= nil
  
  raise SyntaxError, "name #{name} already exists" if @sulley_requests[name]
  @sulley_current = @sulley_requests[name] = Request.new(name, &block)
end
alias_method :response, :request

def session(name, opts = {}, &blk)
  @sulley_sessions ||= {}
  
  @sulley_sessions[name] = RSulley::Session.new(opts) unless @sulley_sessions[name]
  @sulley_sessions[name].run_with_block(@sulley_requests, &blk) if block_given?
  @sulley_sessions[name]
end

def mutate
  @sulley_current.mutate
end

def num_mutations
  @sulley_current.num_mutations
end

def switch(name)
  raise SyntaxError, "name #{name} not found" unless @sulley_requests[name]
  @sulley_current = @sulley_requests[name]
end

def render
  @sulley_current.render
end

def reset
  @sulley_current.reset
end

def reset!
  @sulley_sessions = {}
  @sulley_requests = {}
  @sulley_current  = nil
end

end