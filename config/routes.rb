Simplelogin::Application.routes.draw do

  # The main page of the app is bascally a single-page web-app at this route
  get  "home" => "call/index"

  # The login and logout logic
  get  "auth/login"
  post "auth/login"
  get  "auth/logout"

  # This method provides an RTCC token for the current logged-in user
  post "rtcc/callback"

  # The main page of the app, and the friends method
  get "call/index"
  get "call/friends"

  # The API is primarily used by a mobile app
  get "api/token"
  get "api/appid"
  get "api/friends"
  get "api/me"

  # The cloudrecorder controller proxies AJAX calls to the SightCall Cloud-Recorder
  post "cloudrecorder/recording"
  get  "cloudrecorder/detail"
  post "cloudrecorder/presigned"

  # Text chats are rendered in a separate window by this controller
  get "chat" => "chat#index"

  # You can have the root of your site routed with "root"
  root 'call#index'

  # The admin namespace implements login/logout
  namespace :admin do
    
    get '/', to: redirect('/users')

    # The login and logout logic
    get  "auth/login"
    post "auth/login"
    get  "auth/logout"

  end

  # The users resources are protected by admin credentials
  resources :users

end
