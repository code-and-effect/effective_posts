module EffectivePosts
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      desc 'Creates an EffectivePosts initializer in your application.'

      source_root File.expand_path('../../templates', __FILE__)

      def self.next_migration_number(dirname)
        if not ActiveRecord::Base.timestamped_migrations
          Time.new.utc.strftime("%Y%m%d%H%M%S")
        else
          '%.3d' % (current_migration_number(dirname) + 1)
        end
      end

      def copy_initializer
        template ('../' * 3) + 'config/effective_posts.rb', 'config/initializers/effective_posts.rb'
      end

      def create_migration_file
        @posts_table_name = ':' + EffectivePosts.posts_table_name.to_s

        migration_template ('../' * 3) + 'db/migrate/01_create_effective_posts.rb.erb', 'db/migrate/create_effective_posts.rb'
      end

      def copy_mailer_preview
        mailer_preview_path = (Rails.application.config.action_mailer.preview_path rescue nil)

        if mailer_preview_path.present?
          template 'effective_posts_mailer_preview.rb', File.join(mailer_preview_path, 'effective_posts_mailer_preview.rb')
        else
          puts "couldn't find action_mailer.preview_path.  Skipping effective_posts_mailer_preview."
        end
      end
    end
  end
end
