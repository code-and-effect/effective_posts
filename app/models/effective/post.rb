module Effective
  class Post < ActiveRecord::Base
    attr_accessor :current_user

    acts_as_slugged

    log_changes if respond_to?(:log_changes)
    acts_as_tagged if respond_to?(:acts_as_tagged)
    acts_as_role_restricted if respond_to?(:acts_as_role_restricted)

    has_one_attached :image

    has_rich_text :excerpt
    has_rich_text :body

    self.table_name = EffectivePosts.posts_table_name.to_s

    belongs_to :user, polymorphic: true, optional: true

    effective_resource do
      title             :string
      description       :string

      category          :string
      slug              :string

      draft             :boolean
      published_at      :datetime
      tags              :text

      roles_mask        :integer

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

    validates :title, presence: true, length: { maximum: 255 }
    validates :description, presence: true, length: { maximum: 150 }
    validates :category, presence: true
    validates :published_at, presence: true, unless: -> { draft? }

    validates :start_at, presence: true, if: -> { category == 'events' }

    scope :drafts, -> { where(draft: true) }
    scope :published, -> { where(draft: false).where("#{EffectivePosts.posts_table_name}.published_at < ?", Time.zone.now) }
    scope :unpublished, -> { where(draft: true).or(where("#{EffectivePosts.posts_table_name}.published_at > ?", Time.zone.now)) }
    scope :with_category, -> (category) { where(category: category.to_s.downcase) }

    scope :deep, -> { with_rich_text_excerpt_and_embeds.with_rich_text_body_and_embeds }

    scope :paginate, -> (page: nil, per_page: EffectivePosts.per_page) {
      page = (page || 1).to_i
      offset = [(page - 1), 0].max * per_page

      limit(per_page).offset(offset)
    }

    scope :posts, -> (user: nil, category: nil, unpublished: false) {
      scope = all.deep.order(published_at: :desc)

      if defined?(EffectiveRoles) && EffectivePosts.use_effective_roles
        if user.present? && user.respond_to?(:roles)
          scope = scope.for_role(user.roles)
        end
      end

      if category.present?
        scope = scope.with_category(category)
      end

      unless unpublished
        scope = scope.published
      end

      scope
    }

    def to_s
      title.presence || 'New Post'
    end

    def published?
      !draft? && published_at.present? && published_at < Time.zone.now
    end

    def approved?
      draft == false
    end

    def event?
      category == 'events'
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
      Post.new(attributes.except('id', 'updated_at', 'created_at')).tap do |post|
        post.title = post.title + ' (Copy)'
        post.slug = post.slug + '-copy'
        post.draft = true

        post.body = body
        post.excerpt = excerpt
      end
    end

    def duplicate!
      duplicate.tap { |post| post.save! }
    end

    def approve!
      update!(draft: false)
    end

  end
end
