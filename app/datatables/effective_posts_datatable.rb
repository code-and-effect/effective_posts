unless Gem::Version.new(EffectiveDatatables::VERSION) < Gem::Version.new('3.0')
  class EffectivePostsDatatable < Effective::Datatable
    datatable do
      order :published_at, :desc

      col :published_at
      col :id, visible: false

      col :title
      col :category, search: { collection: EffectivePosts.categories }

      if EffectivePosts.submissions_enabled
        col :approved, sql_column: 'NOT(draft)', as: :boolean do |post|
          post.draft? ? 'No' : 'Yes'
        end

        col :draft, visible: false
      else
        col :draft
      end

      col :created_at, label: 'Submitted at', visible: false

      actions_col partial: '/admin/posts/actions', partial_as: :post
    end

    collection do
      Effective::Post.all
    end
  end
end