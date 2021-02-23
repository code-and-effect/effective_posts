require 'effective_datatables'
require 'effective_resources'
require 'effective_posts/engine'
require 'effective_posts/version'

module EffectivePosts

  def self.config_keys
    [
      :posts_table_name, :layout, :categories,
      :use_category_routes, :use_blog_routes,
      :use_effective_roles, :use_active_storage,
      :per_page, :post_meta_author,
      :submissions_enabled, :submissions_require_current_user,
      :submissions_require_approval, :submissions_note,
      :mailer
    ]
  end

  include EffectiveGem

  def self.permitted_params
    @permitted_params ||= [
      :title, :excerpt, :description, :draft, :category, :slug, :published_at, :body, :tags, :extra,
      :image, :start_at, :end_at, :location, :website_name, :website_href, roles: []
    ]
  end

end
