# frozen_string_literal: true

module Effective
  class Post < ActiveRecord::Base
    self.table_name = (EffectivePosts.posts_table_name || :posts).to_s

    if defined?(PgSearch)
      include PgSearch::Model
      multisearchable against: [:title, :body]
    end

    attr_accessor :current_user

    belongs_to :user, polymorphic: true, optional: true

    acts_as_role_restricted if respond_to?(:acts_as_role_restricted)
    acts_as_archived
    acts_as_published
    acts_as_slugged
    acts_as_tagged if respond_to?(:acts_as_tagged)
    log_changes if respond_to?(:log_changes)

    has_one_attached :image

    has_rich_text :excerpt
    has_rich_text :body

    effective_resource do
      title             :string
      description       :string

      category          :string
      slug              :string

      published_start_at       :datetime
      published_end_at         :datetime
      legacy_draft             :boolean       # No longer used. To be removed.

      tags              :text

      roles_mask        :integer
      archived          :boolean

      # Event Fields
      start_at          :datetime
      end_at            :datetime

      location          :string
      website_name      :string
      website_href      :string

      timestamps
    end

    before_validation(if: -> { current_user.present? }) do
      self.user ||= current_user
    end

    validates :title, presence: true
    validates :description, length: { maximum: 150 }
    validates :category, presence: true
    validates :start_at, presence: true, if: -> { category == 'events' }

    scope :unarchived, -> { where(archived: false) }
    scope :archived, -> { where(archived: true) }

    scope :for_sitemap, -> { published.unarchived }

    # Kind of a meta category
    scope :news, -> { unarchived.where(category: EffectivePosts.news_categories) }
    scope :events, -> { unarchived.where(category: EffectivePosts.event_categories) }

    scope :with_category, -> (category) { where(category: category) } # Don't add unarchived here

    scope :deep, -> { 
      base = with_attached_image.with_rich_text_excerpt_and_embeds.with_rich_text_body_and_embeds 
      base = base.includes(:pg_search_document) if defined?(PgSearch)
      base
    }

    scope :paginate, -> (page: nil, per_page: EffectivePosts.per_page) {
      page = (page || 1).to_i
      offset = [(page - 1), 0].max * per_page

      limit(per_page).offset(offset)
    }

    scope :posts, -> (user: nil, category: nil, unpublished: false, archived: false) {
      scope = all.deep.order(arel_table[:published_start_at].desc.nulls_last)

      # We include member only posts for all users.
      # if defined?(EffectiveRoles) && EffectivePosts.use_effective_roles
      #   scope = scope.for_role(user&.roles)
      # end

      if category.present?
        scope = scope.with_category(category)
      end

      unless unpublished
        scope = scope.published
      end

      unless archived
        scope = scope.unarchived
      end

      scope
    }

    def to_s
      title.presence || 'New Post'
    end

    def approved?
      published?
    end

    def event?
      EffectivePosts.event_categories.include?(EffectivePosts.category(category))
    end

    def start_time
      start_at
    end

    # 3.333 words/second is the default reading speed.
    def time_to_read_in_seconds(reading_speed = 3.333)
      (regions.to_a.sum { |region| (region.content || '').scan(/\w+/).size } / reading_speed).seconds
    end

    def send_post_submitted!
      EffectivePosts.send_email(:post_submitted, self)
    end

    # Returns a duplicated post object, or throws an exception
    def duplicate
      post = Post.new(attributes.except('id', 'updated_at', 'created_at', 'tags'))

      post.assign_attributes(
        title: post.title + ' (Copy)',
        slug: post.slug + '-copy',
        body: body,
        excerpt: excerpt
      )

      post.assign_attributes(published_start_at: nil, published_end_at: nil)

      post
    end

    def duplicate!
      duplicate.tap { |post| post.save! }
    end

    def approve!
      update!(published_start_at: Time.zone.now)
    end

  end
end
