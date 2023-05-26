module Effective
  class PostsMailer < EffectivePosts.parent_mailer_class
    include EffectiveMailer

    helper EffectivePostsHelper

    def post_submitted_to_admin(post_param, opts = {})
      @post = (post_param.kind_of?(Effective::Post) ? post_param : Effective::Post.find(post_param))

      subject = subject_for(__method__, 'Post Submitted', @post, opts)
      headers = headers_for(resource, opts)

      mail(to: mailer_admin, subject: subject, **headers)
    end

  end
end
