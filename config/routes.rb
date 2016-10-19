Rails.application.routes.draw do

  resources 'books'

  get 'scrape', to:'scrape#index', as: 'scrape'
  get 'scrape/rescrape'
  get 'scrape/test'

  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
