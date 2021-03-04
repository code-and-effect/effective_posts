EffectivePosts::Engine.routes.draw do
  namespace :admin do
    resources :posts, except: [:show] do
      post :approve, on: :member
    end
  end

  scope module: 'effective' do
    # Post Routes
    resources :posts

    # Blog Routes
    match 'blog/category/:category', to: 'posts#index', via: :get, constraints: lambda { |req|
      EffectivePosts.use_blog_routes && EffectivePosts.categories.include?(req.params['category'].to_sym)
    }

    resources :posts, only: [:index, :show], path: 'blog', constraints: lambda { |req|
      EffectivePosts.use_blog_routes
    }

    # Category routes
    match ':category', to: 'posts#index', via: :get, constraints: lambda { |req|
      EffectivePosts.use_category_routes && EffectivePosts.categories.include?(req.params['category'].to_sym)
    }

    match ":category/:id", to: 'posts#show', via: :get, constraints: lambda { |req|
      EffectivePosts.use_category_routes && EffectivePosts.categories.include?(req.params['category'].to_sym)
    }
  end

end

Rails.application.routes.draw do
  mount EffectivePosts::Engine => '/', as: 'effective_posts'
end
