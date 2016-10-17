Rails.application.routes.draw do

  resources 'books'

  get 'home/index'

  get 'scrape/index'

  get 'scrape/scrape'

  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
