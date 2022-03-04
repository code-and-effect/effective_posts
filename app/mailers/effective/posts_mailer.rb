module Effective
  class PostsMailer < EffectivePosts.parent_mailer_class
    include EffectiveMailer

    helper EffectivePostsHelper

    def post_submitted(resource, opts = {})
      raise('expected an Effective::Post') unless resource.kind_of?(Effective::Post)

      @post = resource
      subject = subject_for(__method__, 'Post Submitted', resource, opts)
      headers = headers_for(resource, opts)

      mail(to: mailer_admin, subject: subject, **headers)
    end

  end
end
