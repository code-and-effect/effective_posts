module Effective
  class Post < ActiveRecord::Base
    acts_as_role_restricted if defined?(EffectiveRoles)
    acts_as_asset_box :image if defined?(EffectiveAssets)
    acts_as_regionable

    self.table_name = EffectivePosts.posts_table_name.to_s

    belongs_to :user

    # Attributes
    # title             :string
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
    validates :category, presence: true
    validates :published_at, presence: true

    validates :start_at, presence: true, if: -> { category == 'events'}

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
