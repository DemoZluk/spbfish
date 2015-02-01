Spbfish::Application.routes.draw do

  root 'articles#show', id: 'home', as: 'store'

  resources :menu_items, except: :index

  get 'catalog', to: 'store#index'
  get '/catalog/*id' => 'groups#show', as: 'group', constraints: {id: /([\-\w]*\/)?[\-\w]*/}
  resources :catalog,  controller: 'groups', as: 'group' do
    # get ':id/page=:page', action: :show, on: :collection
  end

  resources :products, except: [:new, :create, :destroy] do
    # get :who_bought, on: :member
    get :vote, on: :member
  end

  match 'force_update' => 'products#force_update', via: [:post, :get]
  get '/catalog(/*gid)/*id' => 'products#show', as: 'show_product', constraints: {gid: /([\-\w]*\/)?[\-\w]*/}
  get '/search' => 'products#search'
  get '/download_price' => 'products#download_price', format: 'xlsx'

  post '/bookmark/:product' => 'bookmarks#bookmark_product', as: 'bookmark_product'
  resources :bookmarks, except: [:edit, :update, :show]

  resources :line_items do
    member do
      post 'decrement'
      post 'increment'
    end
  end

  get 'cart' => "carts#show", as: 'cart'
  delete 'cart' => 'carts#clear'
  resources :carts, param: :cid, except: :index do
    collection do
      # get 'merge_yes'
      # get 'merge_no'
    end
  end

  # post  'orders/check' => 'orders#check', as: 'check_order'
  # post  'orders/payment' => 'orders#payment', as: 'payment_order'
  # get   'payment_success' => 'orders#payment_success'
  # get   'payment_failure' => 'orders#payment_failure'
  # match 'yandex-payment' => 'orders#yandex_payment', via: [:get, :post], as: 'yandex_pay'
  resources :orders, except: :index do
    member do
      get 'cancel'
      get 'confirm/:token', action: 'confirm', as: 'confirm'
      get 'payment'
      get 'repeat'
      get 'close'
      get 'print'
      match 'print_preview', via: [:get, :post]
    end
  end
  post 'add_by_item/:id' => 'orders#add_by_item', as: 'add_by_item'

  delete 'multiple_orders' => 'orders#multiple_orders', action: 'delete'

  get 'profile' => 'users#show', as: 'user_root'
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }

  devise_scope :user do
    post '/profile/add_data' => 'users#add_data', as: 'add_data'
    get 'login' => "users/sessions#new"
    post 'login' => "users/sessions#create"
    get 'logout' => "users/sessions#destroy"
    get '/sign_up' => "users#new"
    post '/sign_up' => "users#create"
    get 'profile/edit' => "devise/registrations#edit"
    get 'users' => "users#index"
    get 'user/:id' => "users#show", as: :user
    get 'users/confirm/:t' => "users#confirm", as: 'confirm_user'
  end

  match '/users/batch_create' => "users#batch_create", as: 'batch_create', via: [:post, :get]

  get 'user_prefs' => 'store#change_user_prefs'


  scope '/admin' do
    get 'main' => 'admin#index', as: 'admin_main'
    get 'orders' => 'orders#index', as: 'admin_orders'
    get 'carts' => 'carts#index', as: 'admin_carts'
    get 'products' => 'products#index', as: 'admin_products'
    get 'users' => 'users#index', as: 'admin_users'
    get 'articles' => 'articles#index', as: 'admin_articles'
    get 'menu_items' => 'menu_items#index', as: 'admin_menu_items'
    get 'mailers' => 'mailers#index', as: 'admin_mailers'
  end

  post 'subscribe' => 'mailers#subscribe', as: 'subscribe'
  resources :mailers do
    member do
      get 'start'
      get 'subscribe'
    end
  end
  get '/subscriptions' => 'mailers#subscriptions'
  get '/unsubscribe/:t' => 'mailers#unsubscribe'
  
  get '/contacts' => 'articles#new_feedback'
  post '/contacts' => 'articles#feedback'

  resources :articles, except: :index
  get '/:id' => 'articles#show'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

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
