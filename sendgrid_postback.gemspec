# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sendgrid_postback/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Doug Puchalski"]
  gem.email         = ["doug+github@fullware.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sendgrid_postback"
  gem.require_paths = ["lib"]
  gem.version       = SendgridPostback::VERSION
  
  # specify any dependencies here; for example:
  #s.add_development_dependency "rspec"

  gem.add_runtime_dependency "actionmailer"
  gem.add_runtime_dependency "actionpack"
  gem.add_runtime_dependency "uuidtools"
  gem.add_runtime_dependency "yajl-ruby"
  
end
