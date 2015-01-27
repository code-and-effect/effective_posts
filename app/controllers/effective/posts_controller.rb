module Effective
  class PostsController < ApplicationController
    layout (EffectivePosts.layout.kind_of?(Hash) ? EffectivePosts.layout[:posts] : EffectivePosts.layout)

    def index
      @posts = (Rails::VERSION::MAJOR > 3 ? Effective::Post.all : Effective::Post.scoped)

      if defined?(EffectiveRoles) && (current_user.respond_to?(:roles) rescue false)
        @posts = @posts.for_role(current_user.roles)
      end

      @posts = @posts.includes(:regions)
      @posts = @posts.published if params[:edit].to_s != 'true'
      @posts = @posts.with_category(params[:category]) if params[:category]

      EffectivePosts.authorized?(self, :index, @posts)

      @page_title = (params[:category] || 'Posts').titleize
    end

    def show
      @posts = (Rails::VERSION::MAJOR > 3 ? Effective::Post.all : Effective::Post.scoped)

      if defined?(EffectiveRoles) && (current_user.respond_to?(:roles) rescue false)
        @posts = @posts.for_role(current_user.roles)
      end

      @posts = @posts.includes(:regions)
      @posts = @posts.published if params[:edit].to_s != 'true'
      @posts = @posts.with_category(params[:category]) if params[:category]

      @post = @posts.find(params[:id])

      EffectivePosts.authorized?(self, :show, @post)

      @page_title = @post.title
    end


  end
end
