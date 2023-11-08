module Effective
  class PostsMailer < EffectivePosts.parent_mailer_class
    include EffectiveMailer

    helper EffectivePostsHelper

    def post_submitted_to_admin(resource, opts = {})
      @post = resource
      raise('expected a post') unless resource.kind_of?(Effective::Post)

      subject = subject_for(__method__, 'Post Submitted', resource, opts)
      headers = headers_for(resource, opts)

      mail(to: mailer_admin, subject: subject, **headers)
    end

  end
end
