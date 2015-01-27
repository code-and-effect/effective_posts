module EffectivePostsHelper
  def render_post(post)
    render(:partial => 'effective/posts/post', :locals => {:post => post})
  end

  def post_meta(post)
    [
      "Published",
      "on #{post.published_at.strftime("%d-%b-%Y %l:%M %p")}",
      ("to #{link_to_post_category(post.category)}" if Array(EffectivePosts.categories).length > 0),
      "by #{post.user.to_s.presence || 'Unknown'}"
    ].compact.join(' ').html_safe
  end

  def link_to_post_category(category, options = {})
    category = category.to_s.downcase

    href = EffectivePosts.use_category_routes ? "/#{category}" : effective_posts.posts_path(:category => category.to_s)
    link_to(category.to_s.titleize, href, options)
  end

  def effective_post_path(post)
    category = post.category.to_s.downcase
    EffectivePosts.use_category_routes ? "/#{category}/#{post.to_param}" : effective_posts.post_path(post, :category => category.to_s)
  end

end
