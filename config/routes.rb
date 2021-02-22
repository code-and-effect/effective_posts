EffectivePosts::Engine.routes.draw do
  namespace :admin do
    resources :posts, except: [:show] do
      if EffectivePosts.submissions_enabled && EffectivePosts.submissions_require_approval
        post :approve, on: :member
      end
    end

    match 'posts/excerpts', to: 'posts#excerpts', via: :get
  end

  scope module: 'effective' do
    categories = Array(EffectivePosts.categories).map { |cat| cat.to_s unless cat == 'posts'}.compact
    onlies = ([:index, :show] unless EffectivePosts.submissions_enabled)

    if EffectivePosts.use_blog_routes
      categories.each do |category|
        match "blog/category/#{category}", to: 'posts#index', via: :get, defaults: { category: category }
      end

      resources :posts, only: onlies, path: 'blog'
    elsif EffectivePosts.use_category_routes
      categories.each do |category|
        match category, to: 'posts#index', via: :get, defaults: { category: category }
        match "#{category}/:id", to: 'posts#show', via: :get, defaults: { category: category }
      end

      resources :posts, only: onlies
    else
      resources :posts, only: onlies
    end
  end

end

Rails.application.routes.draw do
  mount EffectivePosts::Engine => '/', :as => 'effective_posts'
end
