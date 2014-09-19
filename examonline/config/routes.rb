Rails.application.routes.draw do
  
  get 'tests/instructions'
  
  get 'tests/finish_test'

  get 'tests/test_paper'

  post 'tests/result'

  get 'admin/home'

  get 'admin/csv_actions'

  get 'users/reset_pass'

  get 'admin/settings'

  get 'admin/stats'
  
  get 'users/adduser'
  
  get 'admin/view'
  
  post 'admin/viewquestions'
  
  get 'admin/viewquestions'
  
  get 'tests/home'
  
  post 'admin/editquestion'
  
  post 'tests/edittest'
  
  delete 'admin/deletequestion'
  
  delete 'admin/deletetest'
  
  post 'admin/view'
  
  post 'tests/settimer'
  
  get 'admin/newques'
  
  get 'admin/newtest'
  
  post 'admin/addtest'
  
  patch 'tests/savetest'
  
  get 'admin/viewtest'
  
  post 'admin/addques'
  
  post 'users/edituser'
  
  post 'users/adminedit'

  delete 'admin/destroyuser'
  
  post 'users/addnew'
  
  post 'users/tryedit'
  
  post 'users/editself'
  
  post 'admin/update'
  
  get 'users/new'

  get 'users/login'
  
  get 'users/logout'

  get 'users/edit'

  get 'users/forgot'

  get 'users/home'
  
  post 'users/create'
  
  post 'tests/test_login'
  
  post 'users/login_attempt'
  
  get 'users/profile'
  
  post 'users/profile'
  
  post 'admin/addcategory'
  
  post 'admin/delcategory'
  
  delete 'admin/destroy_multipletest'
  
  delete 'admin/del_mul_ques'
  
  resources :users do
    collection do
      delete 'destroy_multiple'
    end
  end  
  
  resources :admin do
    collection {
      post :import_questions
    }
  end
  
  resources :admin do
    collection do
      delete 'destroy'
    end
  end 

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
