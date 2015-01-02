Part 4: Adding an API
================================================================

In Part 3 of this series, we put together the HTML and Javascript that
implemented Weemo video calls on the 'index' page of our web site.  We
were able to have multiple users log into the web site, and for user
to create calls to other users.

In Part 4, we will add an API controller.  Rather than render a web
page, the API controller will render JSON objects.  The API will be
used by native mobile clients for iOS and Android.  This means that
authentication for API clients will be different than that used by the
web interface.



Define the routes
----------------

Our API controller will be very simple, with only three methods.
Rather than use a Rails generator, we'll perform all of the steps
manually.  Add the routes for the three new methods by editing the
routes.rb file.  Add the lines shown below.

```ruby
# config/routes.rb
  get "api/token"
  get "api/friends"
  get "api/me"
```



Define the controller
----------------

The API controller is a subclass of the main ApplicationController,
but we want to implement different authentication behavior for our
APIs.  We are going to implement HTTP Basic Authentication for the
APIs with the same username and password as the main web-site.
However, the username and password will be sent in the HTTP headers of
each request.

The first thing to do is to disable the `:authorize` method of the
main ApplicationController.  The following line tells Rails to skip
the `:authorize` before filter for all methods of this controller, as
well as all of its subclasses.

```ruby
   skip_before_filter :authorize
```

For this controller, we will implement a new authorization filter
called `:api_authorize`.  It is shown below.
`authenticate_or_request_with_http_basic` is a Rails built-in method
with a long, unweildy name.  It protects a method with Basic
Authentication and presents username and password provided by the
client to the method for authentication.  We re-use the same
authentication scheme from the main ApplicationController but look for
the username and password in a new context: HTTP Basic.

```ruby
  before_filter :api_authorize

  ...

  def api_authorize
    authenticate_or_request_with_http_basic do |username, password|
      @current_user = User.authenticate(username, password)
    end
  end
```

The API controller implements just three methods, each of which require
a username and password.  The first, called `token`, returns a Weemo
authentication token for the username and password given.  Each time
it is called, a new token will be requested from Weemo.

The `token` method is almost the same as the
`weemo_controller#callback` method in our web site, but we are going
to make one small addition.  The `token` method in the API controller
will insert the Weemo AppID into the JSON object returned.  When we
write a Mobile app, we could tie it to a particular AppID by compiling
it in, but it is a better technique to leave this on the server and
only return it to authenticated clients.  That is the technique we
will implement here.

```ruby
  def token
    if user_signed_in?
      obj = @client.auth(current_user.weemo_uid,
                         current_user.weemo_domain,
                         current_user.weemo_profile)

      obj["appid"] = WEEMO_APP_ID
    else
      obj = { "error" => 500, "error_description" => "unauthenticated user" }
    end

    render :json => obj
  end
```

The second method, called `me`, returns a Weemo User object for the
currently logged-in user.  In this case, this most important piece of
information returned is the "weemo_uid" of the current user.  By
keeping the calculation of the "weemo_uid" on the server (and not in
an API client) the mapping function can be changed without impacting a
mobile client.

```ruby
  def me
    if user_signed_in?
      me = current_user
      obj = { "name" => me.name, "weemo_uid" => me.weemo_uid }
    else
      obj = { "error" => 500, "error_description" => "unauthenticated user" }
    end

    render :json => obj
  end
```

The third method is called `friends`.  In our system, we will consider
everyone in the User database a potential friend.  The `friends`
method returns everyone in the database who is not `me`.

```ruby
  def friends
    @me = current_user
    @friends = User.all.select{ |u| u != @me }

    obj = @friends.map do |f|
      { "name" => f.name, "weemo_uid" => f.weemo_uid }
    end

    render :json => obj
  end
```

The entire controller is presented below.  Note how the `initialize`
method creates an instance of the Weemo Authentication client.  This
is exactly the same client that is used in the `weemo_controller`.


```ruby
# app/controllers/api_controller.rb
require 'weemo_auth'
class ApiController < ApplicationController

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  skip_before_filter :authorize

  before_filter :api_authorize

  def initialize
    @client = WeemoAuth.new(WEEMO_AUTH_URL, WEEMO_CACERT, WEEMO_CLIENTCERT,
                            WEEMO_CLIENTCERT_KEY, WEEMO_CERTPASSWORD, WEEMO_CLIENT_ID, WEEMO_CLIENT_SECRET)
    super
  end

  def token
    if user_signed_in?
      obj = @client.auth(current_user.weemo_uid,
                         current_user.weemo_domain,
                         current_user.weemo_profile)
    else
      obj = { "error" => 500, "error_description" => "unauthenticated user" }
    end

    render :json => obj
  end

  def me
    if user_signed_in?
      me = current_user
      obj = { "name" => me.name, "weemo_uid" => me.weemo_uid }
    else
      obj = { "error" => 500, "error_description" => "unauthenticated user" }
    end

    render :json => obj
  end

  def friends
    @me = current_user
    @friends = User.all.select{ |u| u != @me }

    obj = @friends.map do |f|
      { "name" => f.name, "weemo_uid" => f.weemo_uid }
    end

    render :json => obj
  end

  def api_authorize
    authenticate_or_request_with_http_basic do |username, password|
      @current_user = User.authenticate(username, password)
    end
  end

end
```

A Note About Security: Basic Auth sends passwords in cleartext in the
headers of a request.  It is a good idea to serve these APIs over
HTTPS to keep the passwords safe in a production environment.


Test the controller using Curl
----------------

It is easy to test our API using curl.  Test each of the methods
authenticating as bob.

```shell
$ curl-u bob:bobpassword http://localhost:3000/api/token
{"token":"d7b07dcbd3482c87050219de8badeec72ab01d33", "appid":"ab01cd34ef56" }

$ curl -u bob:bobpassword http://localhost:3000/api/me
{"name":"bob","weemo_uid":"bob-uid"}

$ curl -u bob:bobpassword http://localhost:3000/api/friends
[{"name":"sue","weemo_uid":"sue-uid"},{"name":"tim","weemo_uid":"tim-uid"}]


```


What we learned
----------------

In this part of the tutorial series, we added a simple API controller to our
web application.  The API exposes three methods: one to get a Weemo
token, one to get our Weemo name and UID, and one to get the Weemo
names and UIDs of our friends.  Using these three methods, we will be
able to build a mobile application with the Weemo Mobile SDKs that
interoperates with WebRTC clients.
