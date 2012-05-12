# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mixpanel_rails/version"

Gem::Specification.new do |s|
  s.name        = "mixpanel_rails"
  s.version     = MixpanelRails::VERSION
  s.authors     = ["Paul McMahon"]
  s.email       = ["paul@mobalean.com"]
  s.homepage    = ""
  s.summary     = %q{Easy mixpanel integration for rails}
  s.description = %q{Track stuff using javascript from your controllers, even after redirects}

  s.rubyforge_project = "mixpanel_rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'mixpanel', '~> 1.0.0'
  s.add_dependency 'rails', '~> 3.0'

  s.add_development_dependency 'rspec', '~> 2.5'
  s.add_development_dependency 'capybara', '~> 1.1.1'
  s.add_development_dependency 'steak'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'timecop'
end
