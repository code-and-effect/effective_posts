module Admin
  class PostsController < ApplicationController
    before_filter :authenticate_user! if respond_to?(:authenticate_user!)   # This is devise, ensure we're logged in.

    layout (EffectivePosts.layout.kind_of?(Hash) ? EffectivePosts.layout[:admin] : EffectivePosts.layout)

    def index
      @page_title = 'Posts'
      EffectivePosts.authorized?(self, :index, Effective::Post)

      @datatable = Effective::Datatables::Posts.new() if defined?(EffectiveDatatables)
    end

    def new
      @post = Effective::Post.new(:published_at => Time.zone.now)
      @page_title = 'New Post'

      EffectivePosts.authorized?(self, :new, @post)
    end

    def create
      @post = Effective::Post.new(post_params)
      @post.user = current_user if defined?(current_user)

      @page_title = 'New Post'

      EffectivePosts.authorized?(self, :create, @post)

      if @post.save
        if params[:commit] == 'Save and Edit Content' && defined?(EffectiveRegions)
          redirect_to effective_regions.edit_path(effective_posts.post_path(@post), :exit => effective_posts.edit_admin_post_path(@post))
        elsif params[:commit] == 'Save and Add New'
          redirect_to effective_posts.new_admin_post_path
        else
          flash[:success] = 'Successfully created post'
          redirect_to effective_posts.edit_admin_post_path(@post)
        end
      else
        flash.now[:danger] = 'Unable to create post'
        render :action => :new
      end
    end

    def edit
      @post = Effective::Post.find(params[:id])
      @page_title = 'Edit Post'

      EffectivePosts.authorized?(self, :edit, @post)
    end

    def update
      @post = Effective::Post.find(params[:id])
      @page_title = 'Edit Post'

      EffectivePosts.authorized?(self, :update, @post)

      if @post.update_attributes(post_params)
        if params[:commit] == 'Save and Edit Content' && defined?(EffectiveRegions)
          redirect_to effective_regions.edit_path(effective_posts.post_path(@post), :exit => effective_posts.edit_admin_post_path(@post))
        elsif params[:commit] == 'Save and Add New'
          redirect_to effective_posts.new_admin_post_path
        else
          flash[:success] = 'Successfully updated post'
          redirect_to effective_posts.edit_admin_post_path(@post)
        end
      else
        flash.now[:danger] = 'Unable to update post'
        render :action => :edit
      end
    end

    def destroy
      @post = Effective::Post.find(params[:id])

      EffectivePosts.authorized?(self, :destroy, @post)

      if @post.destroy
        flash[:success] = 'Successfully deleted post'
      else
        flash[:danger] = 'Unable to delete post'
      end

      redirect_to effective_posts.admin_posts_path
    end

    def excerpts
      @page_title = 'Post Excerpts'

      EffectivePosts.authorized?(self, :index, Effective::Post)

      @posts = Effective::Post.includes(:regions)
    end


    private

    def post_params
      params.require(:effective_post).permit(
        :title, :draft, :category, :published_at, :roles => []
      )
    end

  end
end
