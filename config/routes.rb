Payable::Engine.routes.draw do

  root :to => "welcome#index"
  post "welcome/checkout", :controller => "welcome", :action => "checkout"
  get "welcome/json_form", :controller => "welcome", :action => "json_form"

end
