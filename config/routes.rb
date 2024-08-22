resources :projects do
  resources :jobs, shallow: true
end

match '/jobs/:id/quoted', :to => 'journals#new', :id => /\d+/, :via => :post, :as => 'quoted_job'
