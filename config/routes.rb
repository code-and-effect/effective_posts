EffectivePosts::Engine.routes.draw do
  namespace :admin do
    resources :posts, except: [:show] do
      post :approve, on: :member

      post :archive, on: :member
      post :unarchive, on: :member
      post :bulk_archive, on: :collection
      post :bulk_unarchive, on: :collection
    end
  end

  scope module: 'effective' do
    # Post Routes
    resources :posts

    # Blog Routes
    match 'blog/category/:category', to: 'posts#index', via: :get, constraints: lambda { |req|
      EffectivePosts.use_blog_routes && EffectivePosts.category(req.params['category']).present?
    }

    resources :posts, only: [:index, :show], path: 'blog', constraints: lambda { |req|
      EffectivePosts.use_blog_routes
    }

    # Category routes
    match ':category', to: 'posts#index', via: :get, constraints: lambda { |req|
      EffectivePosts.use_category_routes && EffectivePosts.category(req.params['category']).present?
    }

    match ":category/:id", to: 'posts#show', via: :get, constraints: lambda { |req|
      EffectivePosts.use_category_routes && EffectivePosts.category(req.params['category']).present?
    }
  end

end

Rails.application.routes.draw do
  mount EffectivePosts::Engine => '/', as: 'effective_posts'
end
