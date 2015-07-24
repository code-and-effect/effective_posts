if defined?(EffectiveDatatables)
  module Effective
    module Datatables
      class Posts < Effective::Datatable
        datatable do
          default_order :published_at, :desc

          table_column :published_at
          table_column :id, :visible => false

          table_column :title
          table_column :category, :filter => {:type => :select, :values => EffectivePosts.categories }

          table_column :draft

          table_column :actions, :sortable => false, :filter => false, :partial => '/admin/posts/actions'
        end

        def collection
          Effective::Post.all
        end
      end
    end
  end
end
