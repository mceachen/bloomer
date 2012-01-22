# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "bloomer"

Gem::Specification.new do |s|
  s.name        = "bloomer"
  s.version     = Bloomer::VERSION
  s.authors     = ["Matthew McEachen"]
  s.email       = ["matthew+github@mceachen.org"]
  s.homepage    = "https://github.com/mceachen/bloomer"
  s.summary     = %q{Pure-ruby scalable bloom filter}
  s.description = %q{Bloomer implements both simple Bloom filters as well as Scalable Bloom Filters (SBF), in pure ruby and with minimal external dependencies}

  s.rubyforge_project = "bloomer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "bitarray"
end
