# -*- encoding: utf-8 -*-
require File.expand_path('../lib/twitter_backup/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["il.zoff"]
  gem.email         = ["il.zoff@gmail.com"]
  gem.description   = %q{This gem will download your tweets from Twitter and save them in an sqlite3 database and plaintext (yaml) archive file.}
  gem.summary       = %q{Twitter archiver}
  gem.homepage      = "http://github.com/ilzoff/twitter_backup"

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
