# In Rails 4.1 and above, visit:
# http://localhost:3000/rails/mailers
# to see a preview of the following 3 emails:

class EffectivePostsMailerPreview < ActionMailer::Preview
  def post_submitted
    EffectivePosts.mailer_class.post_submitted(build_preview_post)
  end

  protected

  def build_preview_post
    post = Effective::Post.new(
      title: 'An example post',
      category: EffectivePosts.categories.first.presence || 'posts',
      body: 'This is a new post that has been submitted by a public user.'
    )
  end

end
