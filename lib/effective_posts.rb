require 'kaminari'
require 'nokogiri'
require 'effective_resources'
require 'effective_datatables'
require 'effective_regions'
require 'effective_posts/engine'
require 'effective_posts/version'

module EffectivePosts

  def self.config_keys
    [
      :posts_table_name, :permitted_params,
      :layout, :simple_form_options, :admin_simple_form_options,

      :categories, :use_category_routes,
      :use_effective_roles, :use_fullscreen_editor,

      :per_page, :post_meta_author,

      :submissions_enabled, :submissions_require_current_user, :submissions_require_approval, :submissions_note,

    ]
  end

  include EffectiveGem

  def self.mailer_class
    mailer&.constantize || Effective::PostsMailer
  end

  def self.permitted_params
    @@permitted_params ||= [
      :title, :draft, :category, :published_at, :body, :tags, :extra,
      :start_at, :end_at, :location, :website_name, :website_href,
      (EffectiveAssets.permitted_params if defined?(EffectiveAssets)), roles: []
    ].compact
  end

end
