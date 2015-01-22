class EffectivePostsRoutingConstraint
  def self.matches?(request)
    id = request.path_parameters[:id] || '/'
    Effective::Post.find(id).present? rescue false
  end
end

EffectivePosts::Engine.routes.draw do
  if defined?(EffectiveDatatables)
    namespace :admin do
      resources :posts, :except => [:show]
      resources :menus, :except => [:show]
    end
  end

  scope :module => 'effective' do
    get '*id' => "posts#show", :constraints => EffectivePostsRoutingConstraint, :as => :post
  end
end

# Automatically mount the engine as an append
Rails.application.routes.append do
  unless Rails.application.routes.routes.find { |r| r.name == 'effective_posts' }
    mount EffectivePosts::Engine => '/', :as => 'effective_posts'
  end
end

#root :to => 'Effective::Posts#show', :id => 'home'
