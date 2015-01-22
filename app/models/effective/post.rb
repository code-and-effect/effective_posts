module Effective
  class Post < ActiveRecord::Base
    acts_as_role_restricted if defined?(EffectiveRoles)
    acts_as_regionable if defined?(EffectiveRegions)

    self.table_name = EffectivePosts.posts_table_name.to_s

    belongs_to :user

    structure do
      title             :string, :validates => [:presence]
      published_at      :datetime, :validates => [:presence]

      draft             :boolean, :default => false

      tags              :text

      categories_mask   :integer, :default => 0
      roles_mask        :integer, :default => 0


      timestamps
    end

    scope :drafts, -> { where(:draft => true) }
    scope :published, -> { where(:draft => false) }
    scope :with_category, lambda { |*categories| where(with_categories_sql(categories)) }

    def self.with_categories_sql(*categories)
      categories = categories.flatten.compact
      categories = categories.first.try(:categories) if categories.length == 1 and categories.first.respond_to?(:categories)

      categories = (categories.map { |category| category.to_sym } & EffectivePosts.categories)
      categories.map { |role| "(#{self.table_name}.categories_mask & %d > 0)" % 2**EffectivePosts.categories.index(role) }.join(' OR ')
    end

    def categories=(categories)
      self.categories_mask = (categories.map(&:to_sym) & EffectivePosts.categories).map { |r| 2**EffectivePosts.categories.index(r) }.sum
    end

    def categories
      EffectivePosts.categories.reject { |r| ((categories_mask || 0) & 2**EffectivePosts.categories.index(r)).zero? }
    end
  end

end




