# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{amazon-album-art}
  s.version = "0.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Allen"]
  s.date = %q{2011-05-05}
  s.description = %q{A specialized Amazon AWS gem for finding Album Art running on top of the 'sucker' gem}
  s.email = %q{john@threedogconsulting.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "amazon-album-art.gemspec",
    "lib/amazon-album-art.rb",
    "lib/amazon-album-art/client.rb",
    "test/fixtures/albums.json",
    "test/helper.rb",
    "test/test_amazon-album-art.rb"
  ]
  s.homepage = %q{http://github.com/johnallen3d/amazon-album-art}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A specialized Amazon AWS gem for finding Album Art}
  s.test_files = [
    "test/helper.rb",
    "test/test_amazon-album-art.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<nokogiri>, [">= 1.4.4"])
      s.add_development_dependency(%q<sucker>, ["~> 1.5"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4.4"])
      s.add_runtime_dependency(%q<sucker>, [">= 1.1.4"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.4"])
      s.add_dependency(%q<sucker>, ["~> 1.5"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.4"])
      s.add_dependency(%q<sucker>, [">= 1.1.4"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.4"])
    s.add_dependency(%q<sucker>, ["~> 1.5"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.4"])
    s.add_dependency(%q<sucker>, [">= 1.1.4"])
  end
end

