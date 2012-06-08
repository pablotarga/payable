$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "payable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "payable"
  s.version     = Payable::VERSION
  s.authors     = ["Pablo Targa"]
  s.email       = ["pablo.targa@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/payable"
  s.summary     = "Payable é uma engine que se conecta com um gateway de pagamento"
  s.description = "Payable possui forms para chackout e controla a comunicação com um gateway de pagamento."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.5"
  s.add_dependency "state_machine", "~> 1.1.2"
  s.add_dependency "nokogiri", "~> 1.4.7"
  s.add_dependency "httparty", "~> 0.8.3"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
