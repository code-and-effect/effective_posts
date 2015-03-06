module EffectivePostsHelper
  def render_post(post)
    render(partial: 'effective/posts/post', locals: { post: post })
  end

  def post_meta(post)
    [
      'Published',
      "on #{post.published_at.strftime('%d-%b-%Y %l:%M %p')}",
      ("to #{link_to_post_category(post.category)}" if Array(EffectivePosts.categories).length > 0),
      ("by #{post.user.to_s.presence || 'Unknown'}" if EffectivePosts.post_meta_author)
    ].compact.join(' ').html_safe
  end

  def post_excerpt(post, options = {})
    content = effective_region(post, :content) { '<p>Default content</p>'.html_safe }

    # Return excerpt and add a "Read more..." link if read-more divider is present
    index = content.index(Effective::Snippets::ReadMoreDivider::TOKEN)
    return (content[0...index] + readmore_link(post, options)).html_safe if index.present?

    cut_off_limit = (options.delete(:length) || 200)
    # Return untouched content if its length is less that cut-off limit
    return content if content.length <= cut_off_limit

    # Otherwise, truncate content to cut-off limit, strip tags and other snippets in
    # excerpt in order to prevent generating invalid HTML, and add a "Read more..." link
    content = truncate(strip_tags(content), length: cut_off_limit, escape: false, separator: ' ')
    (content + readmore_link(post, options)).html_safe
  end

  def link_to_post_category(category, options = {})
    category = category.to_s.downcase

    href = EffectivePosts.use_category_routes ? "/#{category}" : effective_posts.posts_path(category: category.to_s)
    link_to(category.to_s.titleize, href, options)
  end

  def effective_post_path(post)
    category = post.category.to_s.downcase
    EffectivePosts.use_category_routes ? "/#{category}/#{post.to_param}" : effective_posts.post_path(post, category: category.to_s)
  end

  def readmore_link(post, options)
    content_tag(:p, class: 'post-read-more') do
      link_to((options.delete(:label) || 'Read more...'), effective_post_path(post), options)
    end
  end
end
