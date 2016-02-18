# EffectivePosts Rails Engine

EffectivePosts.setup do |config|
  config.posts_table_name = :posts

  # Every post must belong to one or more category.
  # Don't use the category :posts
  config.categories = [:blog, :news]

  # Create top level routes for each category
  # Should each of the above categories have a top level route created for it
  # For example:
  #   Visiting /blog will display all posts created with the :blog category
  #   Visiting /news will display all posts created with the :news category
  #
  # Regardless of this setting, posts will always be available via /posts?category=blog
  config.use_category_routes = true

  # Number of posts displayed per page (Kaminari)
  config.per_page = 10

  # Post Meta behaviour
  # Should the author be displayed in the post meta?
  # The author is the user that created the Effective::Post object
  config.post_meta_author = true

  # Use CanCan: authorize!(action, resource)
  # Use effective_roles:  resource.roles_permit?(current_user)
  config.authorization_method = Proc.new { |controller, action, resource| true }

  # Layout Settings
  # Configure the Layout per controller, or all at once
  config.layout = {
    :pages => 'application',
    :admin => 'application'
  }

  # SimpleForm Options
  # This Hash of options will be passed into any client facing simple_form_for() calls
  config.simple_form_options = {}
  config.admin_simple_form_options = {}  # For the /admin/posts/new form

  # config.simple_form_options = {
  #   html: {class: 'form-horizontal'},
  #   wrapper: :horizontal_form,
  #   wrapper_mappings: {
  #     boolean: :horizontal_boolean,
  #     check_boxes: :horizontal_radio_and_checkboxes,
  #     radio_buttons: :horizontal_radio_and_checkboxes
  #   }
  # }

  # Submissions
  # Allow users to submit posts (optionally for approval) to display on the website
  config.submissions_enabled = true

  # When true, an Admin must first approve any newly submitted posts before they'll be displayed
  config.submissions_require_approval = true

  # The Thank you message when they submit a post
  config.submissions_note = "News & Event submitted! A confirmation email has been sent to the AALA office. When approved, your submission will appear on the website."

end
