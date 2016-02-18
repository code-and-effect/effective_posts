require 'haml-rails'
require 'kaminari'
require 'nokogiri'
require 'effective_datatables'
require 'effective_regions'
require 'effective_posts/engine'
require 'effective_posts/version'

module EffectivePosts
  mattr_accessor :posts_table_name

  mattr_accessor :authorization_method
  mattr_accessor :permitted_params

  mattr_accessor :layout
  mattr_accessor :simple_form_options
  mattr_accessor :admin_simple_form_options

  mattr_accessor :categories
  mattr_accessor :use_category_routes

  mattr_accessor :per_page
  mattr_accessor :post_meta_author

  mattr_accessor :submissions_enabled
  mattr_accessor :submissions_require_approval
  mattr_accessor :submissions_note

  # These are hashes of configs
  mattr_accessor :mailer

  def self.setup
    yield self
  end

  def self.authorized?(controller, action, resource)
    if authorization_method.respond_to?(:call) || authorization_method.kind_of?(Symbol)
      raise Effective::AccessDenied.new() unless (controller || self).instance_exec(controller, action, resource, &authorization_method)
    end
    true
  end

  def self.permitted_params
    @@permitted_params ||= [:title, :draft, :category, :published_at, :content, :roles => []]
  end

end
