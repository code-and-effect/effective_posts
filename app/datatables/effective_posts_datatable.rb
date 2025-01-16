class EffectivePostsDatatable < Effective::Datatable
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

    col :id, visible: false

    col :title
    col :slug, visible: false
    col :category, search: { collection: EffectivePosts.categories }

    col :draft?, as: :boolean, visible: false
    col :published?, as: :boolean
    col :published_start_at, label: "Published start"
    col :published_end_at, label: "Published end"
    col :roles

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
