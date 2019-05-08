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
  mattr_accessor :use_blog_routes

  mattr_accessor :use_effective_roles
  mattr_accessor :use_fullscreen_editor

  mattr_accessor :per_page
  mattr_accessor :post_meta_author

  mattr_accessor :submissions_enabled
  mattr_accessor :submissions_require_current_user
  mattr_accessor :submissions_require_approval
  mattr_accessor :submissions_note

  # These are hashes of configs
  mattr_accessor :mailer

  def self.setup
    yield self
  end

  def self.authorized?(controller, action, resource)
    @_exceptions ||= [Effective::AccessDenied, (CanCan::AccessDenied if defined?(CanCan)), (Pundit::NotAuthorizedError if defined?(Pundit))].compact

    return !!authorization_method unless authorization_method.respond_to?(:call)
    controller = controller.controller if controller.respond_to?(:controller)

    begin
      !!(controller || self).instance_exec((controller || self), action, resource, &authorization_method)
    rescue *@_exceptions
      false
    end
  end

  def self.authorize!(controller, action, resource)
    raise Effective::AccessDenied.new('Access Denied', action, resource) unless authorized?(controller, action, resource)
  end

  def self.permitted_params
    @@permitted_params ||= [
      :title, :excerpt, :description, :draft, :category, :published_at, :body, :tags, :extra,
      :start_at, :end_at, :location, :website_name, :website_href, roles: []
    ].compact
  end

end
