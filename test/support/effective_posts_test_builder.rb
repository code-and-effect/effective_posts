module EffectivePostsTestBuilder

  def build_effective_post
    category = EffectivePosts.categories.first

    Effective::Post.new(
      title: 'First Post',
      description: 'My really good first post',
      body: "<p>Really good body</p>",
      excerpt: "<p>Really good excerpt</p>",
      category: category,
      published_start_at: Time.zone.now
    )
  end

end
