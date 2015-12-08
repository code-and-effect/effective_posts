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

    validates_presence_of :title, :category, :published_at
    validates_length_of :title, maximum: 255

    scope :drafts, -> { where(:draft => true) }
    scope :published, -> { where(:draft => false).where("#{EffectivePosts.posts_table_name}.published_at < ?", Time.zone.now) }
    scope :with_category, proc { |category| where(:category => category.to_s.downcase) }

    def to_param
      "#{id}-#{title.parameterize}"
    end

    # 3.333 words/second is the default reading speed.
    def time_to_read_in_seconds(reading_speed = 3.333)
      (regions.to_a.sum { |region| (region.content || '').scan(/\w+/).size } / reading_speed).seconds
    end
  end
end
