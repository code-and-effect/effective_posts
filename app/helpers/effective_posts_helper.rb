require 'cgi'

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

  # Only supported options are:
  # :label => 'Read more' to set the label of the 'Read More' link
  # :omission => '...' passed to the final text node's truncate
  # :length => 200 to set the max inner_text length of the content
  # All other options are passed to the link_to 'Read more'
  def post_excerpt(post, opts = {})
    content = effective_region(post, :content, :editable => false) { '<p>Default content</p>'.html_safe }

    options = {
      :label => 'Read more',
      :omission => '...',
      :length => 200
    }.merge(opts)

    divider = content.index(Effective::Snippets::ReadMoreDivider::TOKEN)
    length = options.delete(:length)
    omission = options.delete(:omission)

    CGI.unescapeHTML(if divider.present?
      truncate_html(content, Effective::Snippets::ReadMoreDivider::TOKEN, '') + readmore_link(post, options)
    elsif length.present?
      truncate_html(content, length, omission) + readmore_link(post, options)
    else
      content
    end).html_safe
  end

  def readmore_link(post, options)
    content_tag(:p, class: 'post-read-more') do
      link_to((options.delete(:label) || 'Read more'), effective_posts.post_path(post), options)
    end
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

  def render_post_categories
    categories = EffectivePosts.categories
    return nil unless categories.present?

    render partial: '/effective/posts/categories', locals: { categories: categories }
  end

  def render_recent_posts(user: nil, category: nil, limit: 4)
    posts = Effective::Post.posts(current_user, category).limit(limit)

    render partial: '/effective/posts/recent_posts', locals: { posts: posts }
  end

end
