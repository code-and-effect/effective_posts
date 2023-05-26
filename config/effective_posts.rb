EffectivePosts.setup do |config|
  config.posts_table_name = :posts

  # Every post must belong to one or more category.
  # Don't use the category :posts
  config.categories = [:news, :events]

  # Create top level routes for each category
  # Should each of the above categories have a top level route created for it
  # For example:
  #   Visiting /news will display all posts created with the 'news' category
  #   Visiting /events will display all posts created with the 'events' category
  #
  # Regardless of this setting, posts will always be available via /posts?category=events
  config.use_category_routes = true

  # Number of posts displayed per page (Kaminari)
  config.per_page = 10

  # Post Meta behaviour
  # Should the author be displayed in the post meta?
  # The author is the user that created the Effective::Post object
  config.post_meta_author = true

  # Layout Settings
  # Configure the Layout per controller, or all at once
  config.layout = {
    posts: 'application',
    admin: 'admin'
  }

  # Add additional permitted params
  # config.permitted_params += [:additional_field]

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

  # Display the effective roles 'choose roles' input when an admin creates a new post
  config.use_effective_roles = true

  # Hides the Save and Edit Content links from admin. They can just use the textarea input.
  config.use_fullscreen_editor = true

  # Submissions
  # Allow users to submit posts (optionally for approval) to display on the website
  config.submissions_enabled = true

  # When true, a user might be signed in to submit a post. (calls devise's authenticate_user!)
  config.submissions_require_current_user = false

  # When true, an Admin must first approve any newly submitted posts before they'll be displayed
  config.submissions_require_approval = true

  # The Thank you message when they submit a post
  config.submissions_note = "News & Event submitted! A confirmation email has been sent to the website owner. When approved, your submission will appear on the website."

  # Mailer Settings
  # Please see config/initializers/effective_resources.rb for default effective_* gem mailer settings
  #
  # Configure the class responsible to send e-mails.
  # config.mailer = 'Effective::PostsMailer'
  #
  # Override effective_resource mailer defaults
  #
  # config.parent_mailer = nil      # The parent class responsible for sending emails
  # config.deliver_method = nil     # The deliver method, deliver_later or deliver_now
  # config.mailer_layout = nil      # Default mailer layout
  # config.mailer_sender = nil      # Default From value
  # config.mailer_admin = nil       # Default To value for Admin correspondence
  # config.mailer_subject = nil     # Proc.new method used to customize Subject

end
