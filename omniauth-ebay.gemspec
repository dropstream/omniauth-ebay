# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniauth-ebay/version"

Gem::Specification.new do |s|
  s.name        = "omniauth-ebay"
  s.version     = OmniAuth::Ebay::VERSION
  s.authors     = ["Vladislav Shub"]
  s.email       = ["vlad@yotpo.com"]
  s.homepage    = "https://github.com/YotpoLtd/omniauth-ebay"
  s.summary     = %q{OmniAuth strategy for eBay}
  s.description = %q{In this gem you will find an OmniAuth eBay strategy that is compliant with the Open eBay Apps API.}

  s.rubyforge_project = "omniauth-ebay"

  s.files         = Dir.glob("lib/**/*") + %w(README.md)
  s.test_files    = Dir.glob("spec/**/*")
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'omniauth', '~> 1.0'
  s.add_runtime_dependency "multi_xml", ">= 0.5.2"
  s.add_runtime_dependency "faraday", ">= 0.8.4"

  s.add_development_dependency 'rspec', '~> 2.7'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'capybara-mechanize'
end
