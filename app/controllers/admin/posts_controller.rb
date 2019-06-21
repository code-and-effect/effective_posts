module Admin
  class PostsController < ApplicationController
    before_action(:authenticate_user!) # Devise

    layout (EffectivePosts.layout.kind_of?(Hash) ? EffectivePosts.layout[:admin] : EffectivePosts.layout)

    def index
      @page_title = 'Posts'
      @datatable = EffectivePostsDatatable.new(self)

      authorize_effective_posts!
    end

    def new
      @post = Effective::Post.new(published_at: Time.zone.now)
      @page_title = 'New Post'

      authorize_effective_posts!
    end

    def create
      @post = Effective::Post.new(post_params)
      @post.user = current_user if defined?(current_user)

      @page_title = 'New Post'

      authorize_effective_posts!

      if @post.save
        if params[:commit] == 'Save and Edit Content'
          redirect_to effective_regions.edit_path(effective_posts.post_path(@post), :exit => effective_posts.edit_admin_post_path(@post))
        elsif params[:commit] == 'Save and Add New'
          flash[:success] = 'Successfully created post'
          redirect_to effective_posts.new_admin_post_path
        elsif params[:commit] == 'Save and View'
          redirect_to effective_posts.post_path(@post)
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

      authorize_effective_posts!
    end

    def update
      @post = Effective::Post.find(params[:id])
      @page_title = 'Edit Post'

      authorize_effective_posts!

      if @post.update_attributes(post_params)
        if params[:commit] == 'Save and Edit Content'
          redirect_to effective_regions.edit_path(effective_posts.post_path(@post), :exit => effective_posts.edit_admin_post_path(@post))
        elsif params[:commit] == 'Save and Add New'
          flash[:success] = 'Successfully updated post'
          redirect_to effective_posts.new_admin_post_path
        elsif params[:commit] == 'Save and View'
          redirect_to effective_posts.post_path(@post)
        elsif params[:commit] == 'Duplicate'
          begin
            post = @post.duplicate!
            flash[:success] = 'Successfully saved and duplicated post.'
            flash[:info] = "You are now editing the duplicated post. This new post has been created as a Draft."
          rescue => e
            flash.delete(:success)
            flash[:danger] = "Unable to duplicate post: #{e.message}"
          end

          redirect_to effective_posts.edit_admin_post_path(post || @post)
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

      authorize_effective_posts!

      if @post.destroy
        flash[:success] = 'Successfully deleted post'
      else
        flash[:danger] = 'Unable to delete post'
      end

      redirect_to effective_posts.admin_posts_path
    end

    def approve
      @post = Effective::Post.find(params[:id])
      @page_title = 'Approve Post'

      authorize_effective_posts!

      if @post.update_attributes(draft: false)
        flash[:success] = 'Successfully approved post.  It is now displayed on the website.'
      else
        flash[:danger] = "Unable to approve post: #{@post.errors.full_messages.join(', ')}"
      end

      redirect_to(:back) rescue redirect_to(effective_posts.admin_posts_path)
    end

    def excerpts
      @posts = Effective::Post.includes(:regions)
      @page_title = 'Post Excerpts'

      authorize_effective_posts!
    end

    private

    def authorize_effective_posts!
      EffectivePosts.authorize!(self, :admin, :effective_posts)
      EffectivePosts.authorize!(self, action_name.to_sym, @post || Effective::Post)
    end

    def post_params
      params.require(:effective_post).permit(EffectivePosts.permitted_params)
    end

  end
end
