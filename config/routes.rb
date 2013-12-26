PicdoraBackend::Application.routes.draw do
  resources :categories
  match ':controller(/:action(/:id))', via: :all
end
