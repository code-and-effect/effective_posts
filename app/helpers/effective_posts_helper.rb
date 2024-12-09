require 'cgi'

module EffectivePostsHelper

  # Posts
  def posts_name_label
    et('effective_posts.name')
  end

  # Post
  def post_label
    et(Effective::Post)
  end

  # Posts
  def posts_label
    ets(Effective::Post)
  end

  def effective_posts_header_tags
    return unless @post && @post.kind_of?(Effective::Post) && @post.persisted? && @post.published?

    @effective_pages_og_type = 'article'

    tags = [
      tag(:meta, itemprop: 'author', content: @post.user.to_s),
      tag(:meta, itemprop: 'publisher', content: @post.user.to_s),
      tag(:meta, itemprop: 'datePublished', content: (@post.published_start_at || Time.zone.now).strftime('%FT%T%:z')),
      tag(:meta, itemprop: 'headline', content: @post.title)
    ].join("\n").html_safe
  end

  def effective_post_path(post, opts = nil)
    category = post.category.to_s.downcase.parameterize
    opts ||= {}

    if EffectivePosts.use_blog_routes
      effective_posts.post_path(post, opts)
    elsif EffectivePosts.use_category_routes
      effective_posts.post_path(post, opts).sub('/posts', "/#{category}")
    else
      effective_posts.post_path(post, opts.merge(category: category))
    end
  end

  def effective_post_category_path(category, opts = nil)
    return effective_posts.posts_path(opts || {}) unless category.present?

    category = category.to_s
    category_path = category.to_s.downcase.parameterize
    opts = (opts || {}).compact
    query = ('?' + opts.to_query) if opts.present?

    if EffectivePosts.use_blog_routes
      "/blog/category/#{category_path}#{query}"
    elsif EffectivePosts.use_category_routes
      "/#{category_path}#{query}"
    else
      effective_posts.posts_path(opts.merge(category: category.presence).compact)
    end
  end

  def effective_post_category_url(category, opts = nil)
    root_url.to_s.chomp('/') + effective_post_category_path(category, opts)
  end

  def link_to_post_category(category, options = {})
    category = category.to_s.downcase
    link_to(category.to_s.titleize, effective_post_category_path(category), title: category.to_s.titleize)
  end

  def badge_to_post_category(category, options = {})
    category = category.to_s.downcase
    link_to(category.to_s.titleize, effective_post_category_path(category), title: category.to_s.titleize, class: "badge badge-primary badge-post mb-2 effective-posts-#{category.parameterize}")
  end

  def render_post(post)
    render(partial: 'effective/posts/post', locals: { post: post })
  end

  def post_meta(post, date: true, datetime: false, category: true, author: true)
    [
      ("#{post.published_start_at.strftime('%A, %B %d, %Y')}" if date && post.published_start_at),
      ("#{post.published_start_at.strftime('%A, %B %d, %Y · %l:%M%P')}" if datetime && post.published_start_at),
      ("#{post.user.to_s.presence || 'Unknown'}" if author && EffectivePosts.post_meta_author && post.user.present?)
    ].compact.join(' ').html_safe
  end

  def post_status_badge(post)
    post.roles.map do |role|
      content_tag(:span, "#{role.to_s.upcase} ONLY", class: 'badge badge-secondary')
    end.join(' ').html_safe
  end

  def admin_post_status_badge(post)
    return nil unless EffectiveResources.authorized?(self, :admin, :effective_posts)

    if post.archived?
      content_tag(:span, 'ARCHIVED', class: 'badge badge-secondary')
    elsif post.draft?
      content_tag(:span, 'NOT PUBLISHED', class: 'badge badge-danger')
    elsif post.published? == false
      content_tag(:span, "TO BE PUBLISHED AT #{post.published_start_at&.strftime('%F %H:%M') || 'LATER'}", class: 'badge badge-danger')
    end
  end

  # All other options are passed to the link_to 'Read more'
  def post_excerpt(post, label: 'Continue reading')
    content = post.excerpt.presence || post.body.presence
    (content.to_s + readmore_link(post, label: label)).html_safe
  end

  def read_more_link(post, options = {})
    content_tag(:p, class: 'post-read-more') do
      link_to((options.delete(:label) || 'Continue reading'), effective_post_path(post), (options.delete(:class) || {class: ''}).reverse_merge(options))
    end
  end
  alias_method :readmore_link, :read_more_link

  ### Post Categories

  def post_categories
    categories = EffectivePosts.categories
  end

  def render_post_categories(reverse: false)
    render(partial: '/effective/posts/categories', locals: { categories: (reverse ? post_categories.reverse : post_categories) })
  end

  ### Recent Posts

  def recent_posts(user: current_user, category: nil, limit: EffectivePosts.per_page)
    @recent_posts ||= {}
    @recent_posts[category] ||= Effective::Post.posts(user: user, category: category).limit(limit)
  end

  def render_recent_posts(user: current_user, category: nil, limit: EffectivePosts.per_page)
    posts = recent_posts(user: user, category: category, limit: limit)
    render partial: '/effective/posts/recent_posts', locals: { posts: posts }
  end

  ### Recent News
  def recent_news(user: current_user, category: 'news', limit: EffectivePosts.per_page)
    @recent_news ||= {}
    @recent_news[category] ||= Effective::Post.posts(user: user, category: category).limit(limit)
  end

  def render_recent_news(user: current_user, category: 'news', limit: EffectivePosts.per_page)
    posts = recent_news(user: user, category: category, limit: limit)
    render partial: '/effective/posts/recent_posts', locals: { posts: posts }
  end

  ### Upcoming Events

  def upcoming_events(user: current_user, category: 'events', limit: EffectivePosts.per_page)
    @upcoming_events ||= {}
    @upcoming_events[category] ||= Effective::Post.posts(user: user, category: category).limit(limit)
      .reorder(:start_at).where('start_at > ?', Time.zone.now)
  end

  def render_upcoming_events(user: current_user, category: 'events', limit: EffectivePosts.per_page)
    posts = upcoming_events(user: user, category: category, limit: limit)
    render partial: '/effective/posts/upcoming_events', locals: { posts: posts }
  end

  ### Submitting a Post
  def link_to_submit_post(label = 'Submit a post', options = {})
    link_to(label, effective_posts.new_post_path, options)
  end

end
