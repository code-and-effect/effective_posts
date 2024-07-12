class EffectivePostsDatatable < Effective::Datatable
  bulk_actions do
    bulk_action('Archive selected', effective_posts.bulk_archive_admin_posts_path)
    bulk_action('Unarchive selected', effective_posts.bulk_unarchive_admin_posts_path)
  end

  filters do
    scope :unarchived, label: 'All'
    scope :published
    scope :draft
    scope :news
    scope :events
    scope :archived
  end

  datatable do
    order :published_start_at, :desc

    bulk_actions_col

    col :id, visible: false

    col :title
    col :slug, visible: false
    col :category, search: { collection: EffectivePosts.categories }

    col :draft?, as: :boolean, visible: false
    col :published?, as: :boolean
    col :published_start_at
    col :published_end_at

    col :archived

    col :start_at, visible: EffectivePosts.categories.include?('Events')
    col :end_at, visible: false
    col :location, visible: false
    col :created_at, label: 'Submitted at', visible: false

    actions_col do |post|
      dropdown_link_to('View', effective_post_path(post), target: '_blank')
    end
  end

  collection do
    Effective::Post.all
  end
end
