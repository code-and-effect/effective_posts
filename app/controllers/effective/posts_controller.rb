module Effective
  class PostsController < ApplicationController
    layout (EffectivePosts.layout.kind_of?(Hash) ? EffectivePosts.layout[:posts] : EffectivePosts.layout)

    before_action :authenticate_user!, only: [:new, :create, :edit, :update],
      if: -> { EffectivePosts.submissions_require_current_user }

    def set_admin_preview_flash!
      return unless EffectivePosts.authorized?(self, :admin, :effective_posts)

      if params[:action] == 'index' && (unpublished = Effective::Post.unpublished.length) > 0
        if admin_preview?
          flash.now[:warning] = "<a href='#{effective_posts.posts_path}' class='alert-link'>Click here to return to the normal posts page</a>."
        else
          flash.now[:warning] = "Hi Admin! #{unpublished} #{unpublished > 1 ? 'unpublished posts are' : 'unpublished post is'} hidden from view. " +
            "<a href='#{effective_posts.posts_path(preview: true)}' class='alert-link'>Click here to view unpublished posts</a>."
        end
      end

      if params[:action] == 'show' 
        flash.now[:warning] = [
          'Hi Admin!',
          ('You are viewing a post that is normally hidden from view.' unless @post.published?),
          'Click here to',
          ("<a href='#{effective_regions.edit_path(effective_posts.post_path(@post), exit: effective_posts.post_path(@post, preview: (true unless @post.published?)))}' class='alert-link'>edit post content</a> or" unless admin_edit?),
          ("<a href='#{effective_posts.edit_admin_post_path(@post)}' class='alert-link'>edit settings</a>.")
        ].compact.join(' ')
      end
    end

    def index
      @posts ||= Effective::Post.posts(user: current_user, category: params[:category], drafts: admin_edit_or_preview?)
      @posts = @posts.page(params[:page]).per(EffectivePosts.per_page)

      if params[:category] == 'events'
        @posts = @posts.reorder(:start_at).where('start_at > ?', Time.zone.now)
      end

      if params[:search].present?
        search = params[:search].permit(EffectivePosts.permitted_params).delete_if { |k, v| v.blank? }
        @posts = @posts.where(search) if search.present?
      end

      EffectivePosts.authorize!(self, :index, Effective::Post)

      set_admin_preview_flash! 

      @page_title = (params[:page_title] || params[:category] || params[:defaults].try(:[], :category) || 'Posts').titleize
    end

    def show
      @posts ||= Effective::Post.posts(user: current_user, category: params[:category], drafts: admin_edit_or_preview?)
      @post = @posts.find(params[:id])

      if @post.respond_to?(:roles_permit?)
        raise Effective::AccessDenied.new('Access Denied', :show, @post) unless @post.roles_permit?(current_user)
      end

      EffectivePosts.authorize!(self, :show, @post)

      set_admin_preview_flash!

      @page_title = @post.title
    end

    # Public user submit a post functionality
    def new
      @post ||= Effective::Post.new(published_at: Time.zone.now)
      @page_title = 'New Post'

      EffectivePosts.authorize!(self, :new, @post)
    end

    def create
      @post ||= Effective::Post.new(post_params)
      @post.user = current_user if defined?(current_user)
      @post.draft = (EffectivePosts.submissions_require_approval == true)

      EffectivePosts.authorize!(self, :create, @post)

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

      EffectivePosts.authorize!(self, :edit, @post)
    end

    def update
      @post ||= Effective::Post.find(params[:id])
      draft_was = @post.draft
      @post.draft = (EffectivePosts.submissions_require_approval == true)

      EffectivePosts.authorize!(self, :update, @post)

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

      EffectivePosts.authorize!(self, :destroy, @post)

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

    def admin_edit_or_preview?
      admin_edit? || admin_preview?
    end

    def admin_edit?
      EffectivePosts.authorized?(self, :admin, :effective_posts) && (params[:edit].to_s == 'true')
    end

    def admin_preview?
      EffectivePosts.authorized?(self, :admin, :effective_posts) && (params[:preview].to_s == 'true')
    end

  end
end
