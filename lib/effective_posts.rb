require 'effective_resources'
require 'effective_posts/engine'
require 'effective_posts/version'

module EffectivePosts

  def self.config_keys
    [
      :posts_table_name, :layout, 
      :categories, :event_categories,
      :mailer, :parent_mailer, :deliver_method, :mailer_layout, :mailer_sender, :mailer_admin, :mailer_subject,
      :use_category_routes, :use_blog_routes,
      :use_effective_roles, :use_active_storage,
      :per_page, :post_meta_author,
      :submissions_enabled, :submissions_require_current_user,
      :submissions_require_approval, :submissions_note
    ]
  end

  include EffectiveGem

  def self.mailer_class
    mailer&.constantize || Effective::PostsMailer
  end

  def self.permitted_params
    @permitted_params ||= [
      :title, :excerpt, :description, :save_as_draft, :category, :slug, :published_start_at, :published_end_at, :body, :tags, :extra,
      :image, :start_at, :end_at, :location, :website_name, :website_href, roles: []
    ]
  end

  # Normalize and return the category that matches this value
  def self.category(value, safe: true)
    values = [value, value.to_s, value.to_s.downcase, value.to_s.downcase.parameterize, value.to_s.parameterize]

    category = categories.find do |cat|
      (values & [cat, cat.to_s, cat.to_s.downcase, cat.to_s.downcase.parameterize, cat.to_s.parameterize]).present?
    end

    raise("Unable to find EffectivePosts.category for value '#{value.presence || 'nil'}'") unless safe

    category
  end

  def self.categories
    Array(config[:categories])
  end

  def self.event_categories
    Array(config[:event_categories])
  end

  def self.not_event_categories
    categories - event_categories
  end

  def self.news_categories
    categories - event_categories
  end

end
