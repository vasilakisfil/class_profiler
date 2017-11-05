# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'class_profiler/version'

Gem::Specification.new do |spec|
  spec.name          = "class_profiler"
  spec.version       = ClassProfiler::VERSION
  spec.authors       = ["Filippos Vasilakis"]
  spec.email         = ["vasilakisfil@gmail.com"]

  spec.summary       = %q{Simple class performance profiler with some metaprogramming alcohol}
  spec.description   = %q{Simple class performance profiler with some metaprogramming alcohol}
  spec.homepage      = "https://github.com/vasilakisfil/class_profiler"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
