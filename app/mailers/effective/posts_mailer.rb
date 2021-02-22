module Effective
  class PostsMailer < ActionMailer::Base
    helper EffectivePostsHelper

    layout EffectivePosts.mailer[:layout].presence || 'effective_posts_mailer_layout'

    def post_submitted_to_admin(post_param)
      @post = (post_param.kind_of?(Effective::Post) ? post_param : Effective::Post.find(post_param))

      mail(
        to: EffectivePosts.mailer[:admin_email],
        from: EffectivePosts.mailer[:default_from],
        subject: subject_for_post_submitted_to_admin(@post),
        tenant: (Tenant.current if defined?(Tenant))
      )
    end

    private

    def subject_for_post_submitted_to_admin(post)
      string_or_callable = EffectivePosts.mailer[:subject_for_post_submitted_to_admin]

      if string_or_callable.respond_to?(:call) # This is a Proc or a function, not a string
        string_or_callable = self.instance_exec(post, &string_or_callable)
      end

      prefix_subject(string_or_callable.presence || "A new post has been submitted that needs approval")
    end

    def prefix_subject(text)
      prefix = (EffectivePosts.mailer[:subject_prefix].to_s rescue '')
      prefix.present? ? (prefix.chomp(' ') + ' ' + text) : text
    end
  end
end
