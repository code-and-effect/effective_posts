module Effective
  class PostsController < ApplicationController
    layout (EffectivePosts.layout.kind_of?(Hash) ? EffectivePosts.layout[:posts] : EffectivePosts.layout)

    after_action :monkey_patch_for_kaminari, :only => [:index]

    def index
      @posts = Effective::Post.posts(user: current_user, category: params[:category])
      @posts = @posts.page(params[:page]).per(EffectivePosts.per_page)

      EffectivePosts.authorized?(self, :index, Effective::Post)

      @page_title = (params[:page_title] || params[:category] || 'Posts').titleize
    end

    def show
      @posts = Effective::Post.posts(user: current_user, category: params[:category], drafts: params[:edit].to_s == 'true')
      @post = @posts.find(params[:id])

      if @post.respond_to?(:roles_permit?)
        raise Effective::AccessDenied unless @post.roles_permit?(current_user)
      end

      EffectivePosts.authorized?(self, :show, @post)

      @page_title = @post.title
    end

    private

    def monkey_patch_for_kaminari
      @template = @template.tap { |template| template.extend(EffectiveKaminariHelper) }
    end

  end
end
