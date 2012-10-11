RailsTest3::Application.routes.draw do
resources :check do
  collection do
    post :delete_question,:show_question,:delete_answer,:set_answer
  end
end

  resources :adverts do
    collection do
      post :advert_search,:list_city,:advert_create,:advert_search,:search_city,:advert_delete
      get :advert_list
    end
  end
  resources :vicegerents do
    collection do
      post :vice_search,:vice_create,:vice_update
      get :vice_list
    end
  end
  resources :papers do
    member do
      post :post_block,:create_problem,:post_question
      post :ajax_edit_problem_description,:ajax_edit_problem_title,:ajax_edit_paper_title,:ajax_edit_paper_time
      get :examine,:destroy_element,:preview, :delete
    end
    collection do
      post :select_question_type,:select_correct_type, :sort    #ajax
      post :ajax_load_tags_list,:ajax_insert_new_tag,:ajax_load_words_list #标签管理、词汇管理
      post :upload_image #上传图片
    end
  end

  resources :report_errors do
    collection do
      post :modify_status
      get :other_users
    end
    member do

    end
  end
  resources :specials
  resources :categories
  resources :notices do
    collection do
      post :single_notice
    end
  end
  resources :words do
    collection do
      post :search, :list_similar,:download_word,:create_word, :new_word
      get :search_list
    end
  end
  resources :statistics do
    collection do
      get :user_info,:action_info,:buyer_info,:login_info
    end
  end
  resources :study_plans do
    collection do
      post :create_task,:create_plan,:delete_task
    end
    member do
    end
  end

  resources :users do
    collection do
      post :search
      get :search_list
    end
    member do
      get :category_logs, :user_action_logs, :user_simulations
      post :goto_vip
    end
  end
  resources :similarities do
    member do
      get :statistics, :delete
    end
    collection do
      get :paper_list
      post :get_papers, :set_paper
    end
  end
  resources :simulations do
    member do
      post :update_rater
      get :count_detail, :delete
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
  resources :licenses do
    collection do
      post "search", "generate", "search_vicegerent"
      get "code_details", "search_list"
    end
    member do
      get "invalid", "uninvalid"
    end
  end
  
  resources :phrases do
    collection do
      post :search, :list_similar,:download_word,:create_word, :new_word
      get :search_list
    end
  end

  match '/signout'=> 'sessions#destroy'
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
