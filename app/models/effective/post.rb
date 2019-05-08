module Effective
  class Post < ActiveRecord::Base
    acts_as_role_restricted if defined?(EffectiveRoles) && EffectivePosts.use_effective_roles
    acts_as_regionable

    self.table_name = EffectivePosts.posts_table_name.to_s

    belongs_to :user

    # Attributes
    # title             :string
    # description       :string

    # category          :string

    # draft             :boolean
    # published_at      :datetime
    # tags              :text
    
    # roles_mask        :integer

    # Event Fields
    # start_at          :datetime
    # end_at            :datetime
    # location          :string
    # website_name      :website_name
    # website_href      :website_href

    # timestamps

    validates :title, presence: true, length: { maximum: 255 }
    validates :description, presence: true, length: { maximum: 150 }
    validates :category, presence: true
    validates :published_at, presence: true

    validates :start_at, presence: true, if: -> { category == 'events'}

    scope :drafts, -> { where(draft: true) }
    scope :published, -> { where(draft: false).where("#{EffectivePosts.posts_table_name}.published_at < ?", Time.zone.now) }
    scope :unpublished, -> { where(draft: true).or(where("#{EffectivePosts.posts_table_name}.published_at > ?", Time.zone.now)) }
    scope :with_category, -> (category) { where(category: category.to_s.downcase) }

    scope :paginate, -> (page: nil, per_page: EffectivePosts.per_page) {
      page = (page || 1).to_i
      offset = [(page - 1), 0].max * per_page

      limit(per_page).offset(offset)
    }

    scope :posts, -> (user: nil, category: nil, unpublished: false) {
      scope = all.includes(:regions).order(published_at: :desc)

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
      !draft? && published_at < Time.zone.now
    end

    def approved?
      draft == false
    end

    def event?
      category == 'events'
    end

    def body
      region(:body).content
    end

    def body=(input)
      region(:body).content = input
    end

    def to_param
      "#{id}-#{title.parameterize}"
    end

    # 3.333 words/second is the default reading speed.
    def time_to_read_in_seconds(reading_speed = 3.333)
      (regions.to_a.sum { |region| (region.content || '').scan(/\w+/).size } / reading_speed).seconds
    end

    def send_post_submitted_to_admin!
      send_email(:post_submitted_to_admin, to_param)
    end

    # Returns a duplicated post object, or throws an exception
    def duplicate!
      Post.new(attributes.except('id', 'updated_at', 'created_at')).tap do |post|
        post.title = post.title + ' (Copy)'
        post.draft = true

        regions.each do |region|
          post.regions.build(region.attributes.except('id', 'updated_at', 'created_at'))
        end

        post.save!
      end
    end

    private

    def send_email(email, *mailer_args)
      begin
        if EffectivePosts.mailer[:delayed_job_deliver] && EffectivePosts.mailer[:deliver_method] == :deliver_later
          Effective::PostsMailer.delay.public_send(email, *mailer_args)
        elsif EffectivePosts.mailer[:deliver_method].present?
          Effective::PostsMailer.public_send(email, *mailer_args).public_send(EffectivePosts.mailer[:deliver_method])
        else
          Effective::PostsMailer.public_send(email, *mailer_args).deliver_now
        end
      rescue => e
        raise e unless Rails.env.production?
        return false
      end
    end

  end
end
