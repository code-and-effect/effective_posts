class EffectivePostsDatatable < Effective::Datatable
  bulk_actions do
    bulk_action('Archive selected', effective_posts.bulk_archive_admin_posts_path)
    bulk_action('Unarchive selected', effective_posts.bulk_unarchive_admin_posts_path)
  end

  filters do
    scope :unarchived, label: 'All'
    scope :published
    scope :unpublished
    scope :news
    scope :events
    scope :archived
  end

  datatable do
    order :published_at, :desc

    bulk_actions_col

    col :published_at
    col :id, visible: false

    col :title
    col :slug, visible: false
    col :category, search: { collection: EffectivePosts.categories }

    if EffectivePosts.submissions_enabled
      col :approved, sql_column: 'NOT(draft)', as: :boolean do |post|
        post.draft? ? 'No' : 'Yes'
      end

      col :draft, visible: false
    else
      col :draft
    end

    col :archived

    col :start_at
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
