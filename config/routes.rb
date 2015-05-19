EffectivePosts::Engine.routes.draw do
  namespace :admin do
    resources :posts, :except => [:show]
    match 'posts/excerpts', :to => 'posts#excerpts', :via => [:get]
  end

  scope :module => 'effective' do
    resources :posts, :only => [:index, :show]

    if EffectivePosts.use_category_routes
      EffectivePosts.categories.each do |category|
        next if category.to_s == 'posts'

        match "#{category}", :to => 'posts#index', :via => [:get], :defaults => {:category => category.to_s }
        match "#{category}/:id", :to => 'posts#show', :via => [:get], :defaults => {:category => category.to_s }
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
