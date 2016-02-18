EffectivePosts::Engine.routes.draw do
  namespace :admin do
    resources :posts, except: [:show]
    match 'posts/excerpts', to: 'posts#excerpts', via: :get
  end

  scope :module => 'effective' do
    resources :posts, only: ([:index, :show] unless EffectivePosts.submissions_enabled)

    if EffectivePosts.use_category_routes
      Array(EffectivePosts.categories).map { |category| category.to_s }.each do |category|
        next if category == 'posts'

        match category, to: 'posts#index', via: :get, defaults: {:category => category }
        match "#{category}/:id", to: 'posts#show', via: :get, defaults: {:category => category }
      end
    end
  end

end

# Automatically mount the engine as an append
Rails.application.routes.append do
  unless Rails.application.routes.routes.find { |r| r.name == 'effective_posts' }
    mount EffectivePosts::Engine => '/', :as => 'effective_posts'
  end
end
