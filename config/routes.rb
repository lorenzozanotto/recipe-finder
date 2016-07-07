Rails.application.routes.draw do
  devise_for :users
  resources :recipes do
  	collection do
  		get 'search'
  	end
  end

  root "recipes#index"

end
