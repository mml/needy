spec = Gem::Specification.new do |s| 
  s.name = "needy"
  s.version = "0.0.1"
  s.author = "Matt Liggett"
  s.email = "mml@pobox.com"
  s.homepage = "http://github.com/mml/needy"
  s.platform = Gem::Platform::RUBY
  s.summary = "What needs my attention?"
  s.description = "My brain is too dumb to get it right alone."
  s.files = Dir["{bin,lib}/**/*"].to_a
  s.require_path = "lib"
  #s.autorequire = "name"
  s.test_files = Dir["{test}/**/*test.rb"].to_a
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
  #s.add_dependency("dependency", ">= 0.x.x")
end
