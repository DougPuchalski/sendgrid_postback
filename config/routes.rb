SendgridPostback::Engine.routes.draw do
  resources :events, only: [:create]
end
