PicdoraBackend::Application.routes.draw do
	# TODO: Make better routes instead of doing everything generically.
	
  resources :categories

  put 'images/:id', to: 'images#update'

  match ':controller(/:action(/:id))', via: :all
end
