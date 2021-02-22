module Admin
  class PostsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_posts) }

    include Effective::CrudController

    if (config = EffectivePosts.layout)
      layout(config.kind_of?(Hash) ? config[:admin] : config)
    end

    submit :save, 'Save'
    submit :save, 'Save and View', redirect: -> { effective_posts.post_path(resource) }
    submit :save, 'Duplicate', redirect: -> { effective_posts.new_admin_post_path(duplicate_id: resource.id) }

    def post_params
      params.require(:effective_post).permit!
    end

  end
end
