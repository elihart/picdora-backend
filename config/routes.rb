PicdoraBackend::Application.routes.draw do
	# TODO: Make better routes instead of doing everything generically.
	
  resources :categories
  match ':controller(/:action(/:id))', via: :all
end
