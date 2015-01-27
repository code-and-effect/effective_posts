# This extends the @template.url_for method to work with Kaminari
# It is only extended on the posts#index method, for minimal pollution

module EffectiveKaminariHelper
  def url_for(params)
    if params.kind_of?(Hash) && params[:controller] == 'effective/posts' && params[:action] == 'index'
      params.delete(:page) if params[:page].blank?
      params.delete(:category) if EffectivePosts.use_category_routes
      params = params.except(:action, :controller, :only_path)

      request.path.to_s + (params.present? ? '?' : '') + params.to_param
    else
      super
    end
  end
end
