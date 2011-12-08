RailsTest3::Application.routes.draw do
  

  resources :papers

  resources :categories

  resources :statistics do
    collection do
      get :user_info,:action_info,:buyer_info,:login_info
    end
  end
  resources :study_plans do
    collection do
      post :create_task
    end
  end

  resources :users do
    collection do
      post :search
      get :search_list
    end
    member do
      get :category_logs, :user_action_logs, :user_simulations
    end
  end
  resources :similarities do
    member do
      get :statistics
    end
    collection do
      get :paper_list
      post :get_papers, :set_paper
    end
  end
  resources :simulations do
    member do
      post :update_rater
      get :count_detail
    end
    collection do
      post :add_rater,:delete_rater,:stop_exam
       
    end
  end
  resources :categories do
    member do
      post :edit_post , :add_manage
      get :delete_manage
    end
    collection do
      post :new_post
    end
  end

  resources :sessions do
    collection do
      post "login_from"
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'sessions#new'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
