module Effective
  class Post < ActiveRecord::Base
    acts_as_role_restricted if defined?(EffectiveRoles)
    acts_as_regionable

    self.table_name = EffectivePosts.posts_table_name.to_s

    belongs_to :user

    # structure do
    #   title             :string, :validates => [:presence, :length => {:maximum => 255}]
    #   category          :string, :validates => [:presence]
    #   published_at      :datetime, :validates => [:presence]
    #   draft             :boolean, :default => false
    #   tags              :text
    #   roles_mask        :integer, :default => 0
    #   timestamps
    # end

    validates :title, presence: true, length: { maximum: 255 }
    validates :category, presence: true
    validates :published_at, presence: true

    scope :drafts, -> { where(draft: true) }
    scope :published, -> { where(draft: false).where("#{EffectivePosts.posts_table_name}.published_at < ?", Time.zone.now) }
    scope :with_category, -> (category) { where(category: category.to_s.downcase) }

    scope :posts, -> (user: nil, category: nil, drafts: false) {
      scope = (Rails::VERSION::MAJOR > 3 ? all : scoped)
      scope = scope.includes(:regions).order(published_at: :desc)

      if user.present? && user.respond_to?(:roles) && defined?(EffectiveRoles)
        scope = scope.for_role(user.roles)
      end

      if category.present?
        scope = scope.with_category(category)
      end

      if drafts.blank?
        scope = scope.published
      end

      scope
    }

    def to_s
      title.presence || 'New Post'
    end

    def to_param
      "#{id}-#{title.parameterize}"
    end

    # 3.333 words/second is the default reading speed.
    def time_to_read_in_seconds(reading_speed = 3.333)
      (regions.to_a.sum { |region| (region.content || '').scan(/\w+/).size } / reading_speed).seconds
    end
  end
end
