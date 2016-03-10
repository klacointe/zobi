# encoding: utf-8
Dummy::Application.routes.draw do
  devise_for :users
  namespace :inherited do
    resources :foos do
      collection do
        post :create_with_block
      end
      member do
        put :update_with_block
        delete :destroy_with_block
      end
    end
  end
  namespace :scoped do
    resources :foos
  end
  namespace :paginated do
    resources :foos
  end
  namespace :decorated do
    resources :foos
  end
  namespace :controlled_access do
    resources :foos do
      put :publish, on: :member
    end
  end
  root to: 'home#index'
end
