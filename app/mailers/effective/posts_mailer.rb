module Effective
  class PostsMailer < EffectivePosts.parent_mailer_class
    helper EffectivePostsHelper

    default from: -> { EffectivePosts.mailer_sender }
    layout -> { EffectivePosts.mailer_layout }

    def post_submitted(resource, opts = {})
      raise('expected an Effective::Post') unless resource.kind_of?(Effective::Post)

      @post = resource

      mail(to: EffectivePosts.mailer_admin, **headers_for(resource, opts))
    end

    protected

    def headers_for(resource, opts = {})
      resource.respond_to?(:log_changes_datatable) ? opts.merge(log: resource) : opts
    end

  end
end
