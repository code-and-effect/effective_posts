module Effective
  class PostsController < ApplicationController
    layout (EffectivePosts.layout.kind_of?(Hash) ? EffectivePosts.layout[:posts] : EffectivePosts.layout)

    before_action :authenticate_user!, only: [:new, :create, :edit, :update],
      if: -> { EffectivePosts.submissions_require_current_user }

    after_action :monkey_patch_for_kaminari, only: [:index]

    def index
      @posts ||= Effective::Post.posts(user: current_user, category: params[:category])
      @posts = @posts.page(params[:page]).per(EffectivePosts.per_page)

      EffectivePosts.authorized?(self, :index, Effective::Post)

      @page_title = (params[:page_title] || params[:category] || params[:defaults].try(:[], :category) || 'Posts').titleize
    end

    def show
      @posts ||= Effective::Post.posts(user: current_user, category: params[:category], drafts: (params[:edit].to_s == 'true' || params[:preview].to_s == 'true'))
      @post = @posts.find(params[:id])

      if @post.respond_to?(:roles_permit?)
        raise Effective::AccessDenied unless @post.roles_permit?(current_user)
      end

      EffectivePosts.authorized?(self, :show, @post)

      @page_title = @post.title
    end

    # Public user submit a post functionality
    def new
      @post ||= Effective::Post.new(published_at: Time.zone.now)
      @page_title = 'New Post'

      EffectivePosts.authorized?(self, :new, @post)
    end

    def create
      @post ||= Effective::Post.new(post_params)
      @post.user = current_user if defined?(current_user)
      @post.draft = (EffectivePosts.submissions_require_approval == true)

      EffectivePosts.authorized?(self, :create, @post)

      if @post.save
        @page_title ||= 'Post Submitted'
        flash.now[:success] = 'Successfully submitted post'

        if EffectivePosts.submissions_require_approval
          @post.send_post_submitted_to_admin!
        end

        render :submitted
      else
        @page_title ||= 'New Post'
        flash.now[:danger] = 'Unable to submit post'
        render action: :new
      end
    end

    def edit
      @post ||= Effective::Post.find(params[:id])
      @page_title ||= 'Edit Post'

      EffectivePosts.authorized?(self, :edit, @post)
    end

    def update
      @post ||= Effective::Post.find(params[:id])
      draft_was = @post.draft
      @post.draft = (EffectivePosts.submissions_require_approval == true)

      EffectivePosts.authorized?(self, :update, @post)

      if @post.update_attributes(post_params)
        @page_title ||= 'Post Submitted'
        flash.now[:success] = 'Successfully re-submitted post'

        if EffectivePosts.submissions_require_approval && draft_was != true
          @post.send_post_submitted_to_admin!
        end

        render :submitted
      else
        @page_title ||= 'Edit Post'
        flash.now[:danger] = 'Unable to update post'
        render action: :edit
      end
    end

    def destroy
      @post ||= Effective::Post.find(params[:id])

      EffectivePosts.authorized?(self, :destroy, @post)

      if @post.destroy
        flash[:success] = 'Successfully deleted post'
      else
        flash[:danger] = 'Unable to delete post'
      end

      redirect_to effective_posts.posts_path
    end

    private

    def post_params
      params.require(:effective_post).permit(EffectivePosts.permitted_params)
    end

    def monkey_patch_for_kaminari
      @template = @template.tap { |template| template.extend(EffectiveKaminariHelper) }
    end

  end
end
