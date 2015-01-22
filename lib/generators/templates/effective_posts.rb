# EffectivePosts Rails Engine

EffectivePosts.setup do |config|
  config.posts_table_name = :posts

  # Every post must belong to one or more category
  # Only add to the end of this array.  Never prepend categories.
  config.categories = [:blog, :news, :events]

  # Use CanCan: authorize!(action, resource)
  # Use effective_roles:  resource.roles_match_with?(current_user)
  config.authorization_method = Proc.new { |controller, action, resource| true }

  # Layout Settings
  # Configure the Layout per controller, or all at once
  config.layout = {
    :pages => 'application',
    :admin => 'application'
  }

  # SimpleForm Options
  # This Hash of options will be passed into any simple_form_for() calls
  config.simple_form_options = {}

  # config.simple_form_options = {
  #   :html => {:class => 'form-horizontal'},
  #   :wrapper => :horizontal_form,
  #   :wrapper_mappings => {
  #     :boolean => :horizontal_boolean,
  #     :check_boxes => :horizontal_radio_and_checkboxes,
  #     :radio_buttons => :horizontal_radio_and_checkboxes
  #   }
  # }

end
