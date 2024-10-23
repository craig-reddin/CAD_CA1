Rails.application.routes.draw do
  root to: redirect('/recipes/new')
  resources :recipes do
    collection do
      post "generate_recipe"
    end
  end
end
