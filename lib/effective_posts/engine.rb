module EffectivePosts
  class Engine < ::Rails::Engine
    engine_name 'effective_posts'

    # Include Helpers to base application
    initializer 'effective_posts.action_controller' do |app|
      ActiveSupport.on_load :action_controller_base do
        helper EffectivePostsHelper
      end
    end

    # Set up our default configuration options.
    initializer "effective_posts.defaults", :before => :load_config_initializers do |app|
      # Set up our defaults, as per our initializer template
      eval File.read("#{config.root}/config/effective_posts.rb")
    end
  end
end
