class CreateEffectivePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.string :user_type

      t.string :title
      t.string :description

      t.string :category
      t.string :slug

      t.datetime :published_start_at
      t.datetime :published_end_at
      t.boolean :legacy_draft, default: false

      t.text :tags

      t.integer :roles_mask, default: 0
      t.boolean :archived, default: false

      # Events fields
      t.datetime :start_at
      t.datetime :end_at
      t.string :location
      t.string :website_name
      t.string :website_href

      t.text :extra

      t.datetime :updated_at
      t.datetime :created_at
    end

    add_index :posts, [:user_id, :user_type], if_not_exists: true
    add_index :posts, [:published_start_at, :published_end_at], if_not_exists: true
    add_index :posts, :archived, if_not_exists: true
  end
end
