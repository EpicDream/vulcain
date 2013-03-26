require 'minitest/autorun'

def require_lib libname
  require File.join(File.dirname(__FILE__), "../lib/#{libname}")
end
require_lib 'driver'
require_lib 'strategy'


require 'mocha'