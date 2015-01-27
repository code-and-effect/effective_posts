module Effective
  class Post < ActiveRecord::Base
    acts_as_role_restricted if defined?(EffectiveRoles)
    acts_as_regionable if defined?(EffectiveRegions)

    self.table_name = EffectivePosts.posts_table_name.to_s

    belongs_to :user

    structure do
      title             :string, :validates => [:presence]
      category          :string, :validates => [:presence]

      published_at      :datetime, :validates => [:presence]

      draft             :boolean, :default => false

      tags              :text

      roles_mask        :integer, :default => 0

      timestamps
    end

    scope :drafts, -> { where(:draft => true) }
    scope :published, -> { where(:draft => false) }
    scope :with_category, proc { |category| where(:category => category.to_s.downcase) }

    def to_param
      "#{id}-#{title.parameterize}"
    end

  end

end




