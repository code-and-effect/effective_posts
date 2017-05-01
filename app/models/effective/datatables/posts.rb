if Gem::Version.new(EffectiveDatatables::VERSION) < Gem::Version.new('3.0')
  module Effective
    module Datatables
      class Posts < Effective::Datatable
        datatable do
          default_order :published_at, :desc

          table_column :published_at
          table_column :id, visible: false

          table_column :title
          table_column :category, filter: { type: :select, values: EffectivePosts.categories }

          if EffectivePosts.submissions_enabled
            table_column :approved, column: 'NOT(draft)', as: :boolean do |post|
              post.draft ? 'No' : 'Yes'
            end

            table_column :draft, visible: false
          else
            table_column :draft
          end

          table_column :start_at
          table_column :end_at, visible: false
          table_column :location, visible: false

          table_column :created_at, label: 'Submitted at', visible: false

          table_column :actions, sortable: false, filter: false, partial: '/admin/posts/actions'
        end

        def collection
          Effective::Post.all
        end
      end
    end
  end
end
