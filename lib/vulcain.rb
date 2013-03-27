# -*- encoding : utf-8 -*-
require "selenium-webdriver"
require_relative 'driver'
require_relative 'strategy'

def require_strategy name
  require File.join(File.dirname(__FILE__), "strategies/#{name}/#{name}")
end

module Vulcain
end