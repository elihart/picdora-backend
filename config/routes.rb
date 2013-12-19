PicdoraBackend::Application.routes.draw do
  match ':controller(/:action(/:id))', via: :all
end
