module Effective
  class PostsController < ApplicationController
    layout (EffectivePosts.layout.kind_of?(Hash) ? EffectivePosts.layout[:posts] : EffectivePosts.layout)

    after_action :monkey_patch_for_kaminari, :only => [:index]

    def index
      @posts = Effective::Post.posts(current_user, params[:category])
      @posts = @posts.page(params[:page]).per(EffectivePosts.per_page)

      EffectivePosts.authorized?(self, :index, Effective::Post)

      @page_title = (params[:category] || 'Posts').titleize
    end

    def show
      @posts = (Rails::VERSION::MAJOR > 3 ? Effective::Post.all : Effective::Post.scoped)

      @posts = @posts.with_category(params[:category]) if params[:category]
      @posts = @posts.published if params[:edit].to_s != 'true'
      @posts = @posts.includes(:regions)

      @post = @posts.find(params[:id])

      if defined?(EffectiveRoles)
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
