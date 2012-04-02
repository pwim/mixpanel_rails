require 'bundler/setup'
require 'rails'
Bundler.require(:default, Rails.env)
require 'action_controller/railtie'
require 'action_view/railtie'

app = Class.new(Rails::Application)
app.config.root = File.dirname(__FILE__)
app.config.secret_token = "3b7cd727ee24e8444053437c36cc66c4"
app.config.active_support.deprecation = :log
app.config.mixpanel_rails.token = "test_token"
app.initialize!

app.routes.draw do
  match ':controller(/:action(/:id))'
end

class ApplicationController < ActionController::Base; end
