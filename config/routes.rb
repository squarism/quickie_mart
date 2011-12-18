Store::Application.routes.draw do
  resources :products

  # order matters, first is highest priority  resources :users
 
  match 'carts/add/:id' => 'carts#add', :as => :add_to_carts
  match 'carts/clear' => 'carts#clear'
  resources :carts

  root :to => 'products#index'
end

