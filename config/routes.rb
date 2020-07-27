Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'homepage#index'
  post 'api/interactions' => 'api#interactions'
  post 'api/shoutout-data' => 'api#shoutout_data'
  get 'homepage/index'
end
