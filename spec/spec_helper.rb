$:.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path(File.dirname(__FILE__) + "/app/fake")
require 'rspec/rails'
require "steak"
require 'capybara/rspec'
