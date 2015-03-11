module EffectivePostsHelper
  def render_post(post)
    render(partial: 'effective/posts/post', locals: { post: post })
  end

  def post_meta(post)
    [
      'Published',
      "on #{post.published_at.strftime('%B %d, %Y at %l:%M %p')}",
      ("to #{link_to_post_category(post.category)}" if Array(EffectivePosts.categories).length > 1),
      ("by #{post.user.to_s.presence || 'Unknown'}" if EffectivePosts.post_meta_author)
    ].compact.join(' ').html_safe
  end

  def post_excerpt(post, options = {})
    content = effective_region(post, :content) { '<p>Default content</p>'.html_safe }

    length = options.delete(:length)
    divider_pos = content.index(Effective::Snippets::ReadMoreDivider::TOKEN)

    return content if (length.nil? && divider_pos.nil?) || (length.present? && divider_pos.nil? && content.length < length)

    only_divider_pos_present = length.nil? && divider_pos.present?
    divider_pos_less_than_length = length.present? && divider_pos.present? && divider_pos < length

    cut_off_limit = only_divider_pos_present || divider_pos_less_than_length ? divider_pos : length

    content = truncate_html(content, cut_off_limit)
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
      link_to((options.delete(:label) || 'Read more...'), effective_posts.post_path(post), options)
    end
  end
end
