# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pg_drive/version"

Gem::Specification.new do |spec|
  spec.name          = "pg_drive"
  spec.version       = PgDrive::VERSION
  spec.authors       = ["Gal Tsubery"]
  spec.email         = ["gal.tsubery@gmail.com"]

  spec.summary       = "Backup rails postgres to google drive"
  spec.description   = "This gem backs up postgres and stores the backup in google drive"
  spec.homepage      = "http://github.com/tsubery/pg_drive/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`
                       .split("\x0")
                       .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "pry"
  spec.add_dependency "google-api-client", "0.9"
  spec.add_dependency "pg" # Just to make sure we are using postgres
  spec.add_dependency "rails", [">4.0.0", "<6.0.0"]
  # Just to make sure we are using postgres
end
