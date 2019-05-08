$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'effective_posts/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'effective_posts'
  s.version     = EffectivePosts::VERSION
  s.authors     = ['Code and Effect']
  s.email       = ['info@codeandeffect.com']
  s.homepage    = 'https://github.com/code-and-effect/effective_posts'
  s.summary     = 'A blog implementation with WYSIWYG content editing, post scheduling, pagination and optional top level routes for each post category.'
  s.description = 'A blog implementation with WYSIWYG content editing, post scheduling, pagination and optional top level routes for each post category.'
  s.licenses    = ['MIT']

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'README.md']

  s.add_dependency 'rails', ['>= 3.2.0']
  s.add_dependency 'sass'
  s.add_dependency 'nokogiri'
  s.add_dependency 'effective_bootstrap'
  s.add_dependency 'effective_ckeditor'
  s.add_dependency 'effective_datatables', '>= 4.0.0'
  s.add_dependency 'effective_regions'
end
