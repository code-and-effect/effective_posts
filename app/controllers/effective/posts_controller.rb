module Effective
  class PostsController < ApplicationController
    layout (EffectivePosts.layout.kind_of?(Hash) ? EffectivePosts.layout[:posts] : EffectivePosts.layout)

    after_action :monkey_patch_for_kaminari, :only => [:index]

    def index
      @posts = (Rails::VERSION::MAJOR > 3 ? Effective::Post.all : Effective::Post.scoped)

      if defined?(EffectiveRoles) && (current_user.respond_to?(:roles) rescue false)
        @posts = @posts.for_role(current_user.roles)
      end

      @posts = @posts.includes(:regions)
      @posts = @posts.with_category(params[:category]) if params[:category]
      @posts = @posts.published

      @posts = @posts.order("#{EffectivePosts.posts_table_name}.published_at DESC")
      @posts = @posts.page(params[:page]).per(EffectivePosts.per_page)

      EffectivePosts.authorized?(self, :index, @posts)

      @page_title = (params[:category] || 'Posts').titleize
    end

    def show
      @posts = (Rails::VERSION::MAJOR > 3 ? Effective::Post.all : Effective::Post.scoped)

      if defined?(EffectiveRoles) && (current_user.respond_to?(:roles) rescue false)
        @posts = @posts.for_role(current_user.roles)
      end

      @posts = @posts.includes(:regions)
      @posts = @posts.with_category(params[:category]) if params[:category]
      @posts = @posts.published if params[:edit].to_s != 'true'

      @post = @posts.find(params[:id])

      EffectivePosts.authorized?(self, :show, @post)

      @page_title = @post.title
    end

    private

    def monkey_patch_for_kaminari
      @template = @template.tap { |template| template.extend(EffectiveKaminariHelper) }
    end

  end
end
