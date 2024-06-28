module Effective
  class PostsController < ApplicationController
    if defined?(Devise)
      before_action :authenticate_user!, only: [:new, :create, :edit, :update],
        if: -> { EffectivePosts.submissions_require_current_user }
    end

    include Effective::CrudController

    def index
      @category = EffectivePosts.category(params[:category])

      @posts ||= Effective::Post.posts(
        user: current_user,
        category: @category,
        unpublished: EffectiveResources.authorized?(self, :admin, :effective_posts)
      )

      @posts = @posts.paginate(page: params[:page])

      if EffectivePosts.event_categories.include?(@category)
        @posts = @posts.reorder(:start_at).where('start_at > ?', Time.zone.now)
      end

      if params[:search].present?
        search = params[:search].permit(EffectivePosts.permitted_params).delete_if { |k, v| v.blank? }
        @posts = @posts.where(search) if search.present?
      end

      EffectiveResources.authorize!(self, :index, Effective::Post)

      @page_title ||= [(@category || 'Blog').to_s.titleize, (" - Page #{params[:page]}" if params[:page])].compact.join
      @canonical_url ||= helpers.effective_post_category_url(params[:category], page: params[:page])
    end

    def show
      @category = EffectivePosts.category(params[:category])

      admin = EffectiveResources.authorized?(self, :admin, :effective_posts)

      @posts ||= Effective::Post.posts(user: current_user, unpublished: admin, archived: admin)
      @post = @posts.find(params[:id])

      if @post.respond_to?(:roles_permit?)
        raise Effective::AccessDenied.new('Access Denied', :show, @post) unless @post.roles_permit?(current_user)
      end

      EffectiveResources.authorize!(self, :show, @post)

      if admin 
        flash.now[:warning] = [
          'Hi Admin!',
          ('You are viewing a hidden post.' unless @post.published?),
          ('You are viewing an archived post.' if @post.archived?),
          'Click here to',
          ("<a href='#{effective_posts.edit_admin_post_path(@post)}' class='alert-link'>edit post settings</a>.")
        ].compact.join(' ')
      end

      @page_title ||= @post.title
      @meta_description ||= @post.description
      @canonical_url ||= effective_posts.post_url(@post)
    end

    # Public user submit a post functionality
    def new
      @post ||= Effective::Post.new
      @page_title = 'New Post'

      EffectiveResources.authorize!(self, :new, @post)
    end

    def create
      @post ||= Effective::Post.new(post_params)
      @post.user = current_user if defined?(current_user)
      @post.draft = (EffectivePosts.submissions_require_approval == true)

      EffectiveResources.authorize!(self, :create, @post)

      if @post.save
        @page_title ||= 'Post Submitted'
        flash.now[:success] = 'Successfully submitted post'

        if EffectivePosts.submissions_require_approval
          @post.send_post_submitted!
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

      EffectiveResources.authorize!(self, :edit, @post)
    end

    def update
      @post ||= Effective::Post.find(params[:id])
      draft_was = @post.draft
      @post.draft = (EffectivePosts.submissions_require_approval == true)

      EffectiveResources.authorize!(self, :update, @post)

      if @post.update(post_params)
        @page_title ||= 'Post Submitted'
        flash.now[:success] = 'Successfully re-submitted post'

        if EffectivePosts.submissions_require_approval && draft_was != true
          @post.send_post_submitted!
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

      EffectiveResources.authorize!(self, :destroy, @post)

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

    def admin_edit?
      EffectiveResources.authorized?(self, :admin, :effective_posts) && (params[:edit].to_s == 'true')
    end

  end
end
