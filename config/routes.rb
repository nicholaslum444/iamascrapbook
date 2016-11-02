Rails.application.routes.draw do

  resources 'books'

  get 'scrape', to:'scrape#index', as: 'scrape'
  get 'scrape/rescrape'
  get 'test', to: 'scrape#test', as: 'test'

  get 'admin', to: 'scrape#index', as: 'admin'

  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
