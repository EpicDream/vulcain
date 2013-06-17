#!/usr/bin/env ruby
ENV['DISPLAY'] = ':0' if ENV['DISPLAY'].nil?
require File.join(File.dirname(__FILE__), '../lib/core/vulcain')
Vulcain.spawn_new_worker