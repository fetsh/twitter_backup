# -*- encoding: utf-8 -*-
require File.expand_path('../lib/twitter_backup/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["il.zoff"]
  gem.email         = ["il.zoff@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "twitter_backup"
  gem.require_paths = ["lib"]
  gem.version       = TwitterBackup::VERSION

  gem.add_dependency("highline")
  gem.add_dependency("activesupport")
  gem.add_dependency("activerecord")
  gem.add_dependency("sqlite3")
  gem.add_dependency("twitter")
  gem.add_dependency("slop")

end
