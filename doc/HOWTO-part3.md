Part 3: Weemo Javascript and Video Calls
================================================================

In Part 2 of this series, we added the Ruby authentication client for
Weemo to a Rails web site.  When we were done, the web site was able to
provide a Weemo authentication token for the current logged-in user.

In Part 3 of this series, we will add Weemo Javascript to a web page
and create a fully functional video call system.  By working through
this example you will learn about how to include the Weemo Javascript,
how to initialize the Weemo Javascript object, and how to make and
receive one-to-one Video calls using WebRTC.


Add the Weemo Javascript to your Site
----------------

Open the main template for your site and add a `<script>` tag to
load the Weemo Javascript.  You should place this tag in the
`<head>` section of your project.  


```html
app/views/layout/application.html.erb

<head>
  <title>My Project</title>
  <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" />
  <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" />
  <script src="//download.weemo.com/js/webappid/<%= WEEMO_APP_ID %>" ></script>
  <%= stylesheet_link_tag    "application", media: "all" %>
  <%= javascript_include_tag "application" %>
  <%= csrf_meta_tags %>
</head>
```

You'll notice that the particular script downloaded for your project
is tied to your Weemo AppID.  In the code above, we interpolated the
value of the global variable WEEMO_APP_ID that you defined in
config/environment.rb earlier.


Define the Video Box
----------------

All of the action will take place in a single page of our web site.
On this page, first define an area for Weemo to render the WebRTC
video window and to place its widgets.

In file app/views/call/index.html.erb, add a container and a
video-container like this.

```html
<h1>Call</h1>

<div class="container">
  <div class="row">
    <div class="col-sm-4">
      <div id="video-container" style="width:320px; height:180px; background:#0074bc; border: 1px solid black;">
      </div>
    </div>
  </div>
</div>

```

The ID of this element is "video-container" - we'll need this later
when we initialize the Weemo object.


Define a list of friends to call
----------------

Recall that the index method in our call_controller didn't do
anything.  Let's change that.  Open up
app/controllers/call_controller.rb and modify the index method to
compute a list of the friends a user might want to call.


```ruby
# app/controllers/call_controller.rb
  def index
    @me = current_user
    @friends = User.all.select{ |u| u != @me }
  end
```

Now our index method creates a list of all users in the system who are
not the current user (me).  We can use the list of friends in the view
we are working on.


Add some buttons to call friends
----------------

Now go back to the index page and add some buttons.  Beneath the video
box add the following code.

```html
# app/vews/call/index.html.erb

<div class="container">
  <div class="row">
    <% @friends.each do |f| %>
      <div class="col-sm-1">
        <center>
          <button class="btn btn-large" onclick="callFriend('<%= f.weemo_uid %>')"><%= f.name %></button>
        </center>
      </div>
    <% end %>
  </div>

  <div class="row">
    <div class="col-sm-4">
      <button class="btn btn-large btn-primary btn-block" onclick="hangup()">Hangup</button>
  </div>
  </div>
</div>

```

Most of this is straight HTML and CSS.  There is some Rails ERB
interpolation too.  The line that has `@friends.each` in it
iterates over the list of friends assigning each friend to the
variable `f`.  For each friend, the template creates a div that
holds a button that calls the Javascript `callFriend` function.
(We'll define this function soon.)  The thing to notice here is that
we are rendering the `f.name` of the friend and sending the
`f.weemo_uid` of the friend to the `callFriend` Javascript function.

The Hangup button will hang up the current call.  We'll implement that
soon too.


Test Your Work
----------------

At this point it is a good idea to start up your Rails server and test
it out.

```shell
$ bin/rails server
```

You can see your website at
[http://localhost:3000/](http://localhost:3000/).  Login if you are
not already, and view the page.  You should see something like the
image below.  The video box will be there as will be the buttons for
your friends.  Next, we'll add functionality using Javascript.

![Call Page](../images/call_page_layout_med.png)

Write the Javascript Code
----------------

We are going to add a big block of Javascript code into the page.
Add this after the video box and the buttons we defined earlier.
We'll describe what each of the pieces are doing here and how the
whole application fits tother.

The first three lines define some page-global variables.  The var `weemoAppId`
is taken from the Rails global variables you defined in
config/environment.rb.  Here we render it into the page and assign it
to a Javascript Variable.  Variables `weemo` and `weemoCall` will hold
references to the main Weemo object, and to the current call.

The `initializeWeemo` function will set some options and callbacks
before initializing the Weemo session.  It's fairly complicated.


```javascript
# app/views/call/index.html.erb

<script>
 var weemoAppId = "<%= WEEMO_APP_ID %>";
 var weemo = null;
 var weemoCall = null;

 function initializeWeemo(weepAppId, token, displayName) {
   var options = {
     debugLevel: 4,
     displayName: displayName,
     container: 'video-container'
   };

   weemo = new Weemo(weemoAppId, token, 'internal', options);

   weemo.onConnectionHandler = function(message, code) {
     console.log(['onConnectionHandler', message, code]);
     switch(message) {
       // Authenticate
       case 'connectedWeemoDriver':
       case 'connectedWebRTC':
         weemo.authenticate();
         break; 
       case 'sipOk':
         break;
       case 'sipNok':
         break;
       case 'loggedasotheruser':
         weemo.authenticate(1);
         break;
     }
   }
     
     weemo.onCallHandler = function(call, args) {
       console.log(['onCallHandler', call, args]);
       weemoCall = call;

       // Handle incoming call
       if (args.type == 'webRTCcall' && args.status == 'incoming') {
         var ans = confirm("Accept call from '" + call.dn + "'?");
         if (ans == true) {
           weemoCall.accept();
       }
         else {
           weemoCall.hangup();
       }
     }

       // Handle refused call
       if (args.status == 'terminated' && args.reason == 'rejected') {
         alert("Call rejected");
     }
   }

   weemo.initialize();
 }

 function callFriend(friend) {
   weemo.createCall(friend, 'internal', "<%= current_user.name %>");
 }

 function hangup() {
   weemoCall.hangup();
 }

 function documentReady() {

   $.ajax({
     type: "POST",
     url: "/weemo/callback",
     cache: false,
     dataType: "JSON"
   }).success(function(data) {
     console.log(["WeemoToken Success", data]);
     var token = data.token;
     initializeWeemo(weemoAppId, token, "<%= current_user.name %>");
   }).error(function(e) {
     console.log(["WeemoToken error", e]);
   });
 }

 $(document).ready(documentReady);

</script>

```


#### The initializeWeemo function

The arguments to this function are the AppID, a user token and the
display name of the current user.  These will be used to initialize
the global Weemo object.

The options array sets a wide variety of parameters for the Weemo
session.  The main item of interest here is the container parameter.
This gives the ID of the DOM element that will hold the Weemo video
box.

Next, we initialize the global Weemo object.

```
   weemo = new Weemo(weemoAppId, token, 'internal', options);
```

This statement allocates data structures and sets up some state.  The
main purpose of this statement is to allocate us an object on which to
assign callback handlers that will customize the Weemo experience.
There are many callback handlers, with many options.  In this
tutorial, we are showing how to define a minimal application, so we
only register for a few callbacks and only notice a few event types.

##### The onConnectionHandler

The onConnectionHandler callback indicates various events in the
lifetime of an internet connection from the browser to the Weemo
Core.  What we've shown here is boilerplate for most minimal
installations.  Upon the 'connectedWebRTC' or 'connectedWeemoDriver'
event, we kick off the next phase of initialization by calling
`weemo.authenticate()`.

##### The onCallHandler

The onCallHandler callback is called in many different contexts to
indicate many changes in the state of a video call.  Its two arguments
are a `call` object, and an `args` object.  In our handler, we
set assign the global `weemoCall` to the current call object.

In this simple tutorial we are only implementing two behaviors.  When
we receive an incoming WebRTC call we present the user a confirmation
box asking them if they want to accept the call or not.  If they
confirm the choice we accept the call with `weemoCall.accept()`,
if not, we terminate the call with `weemoCall.hangup()`.

The other behavior that this callback defines is what we do if the
user at the remote end rejects our call.  We can examine the
`args` object for the reason a call was terminated.  If it was
rejected we pop up a Javascript alert saying so.


After the Weemo object has been initialized and we have attached
callback handlers, we can finally call `initialize()` to kick off the
Weemo session.  It is this method call that causes the Weemo
Javascript to launch an internet connection to Weemo and to register
the browser as an endpoint on the global Weemo network.


#### The rest of the Javascript

The `callFriend` and `hangup` functions are simple.  The `callFriend`
function takes the UID of another Weemo user and launches a new video
call directed to that UID.  The `hangup` function simply calls `hangup` on the
current call.

We define a `documentReady` function that is called when the entire
page has loaded.  This function launches the AJAX call that grabs a
token from the Rails server for the current logged-in user.  Once we
have the token, the `initializeWeemo` function is called with the
`weemoAppId` and name of the current user.


## Try it out!

To test the web site you'll need two computers.  Open up our demo web
site on both computers and log in as 'bob' on one computer and 'sue'
on the other.

On the 'sue' computer click the 'bob' button.  A dialog box will pop
up on Bob's page asking if he will accept the call from Sue.  Click
"OK".

![Call Accept](../images/call_accept_med.png)

After the incoming call is accepted, the video call will be set up
between the two browsers and Sue will be chatting with Bob.



![Call Active](../images/call_active_med.png)


## What we have learned

In Part 3 of this tutorial series we showed how to integrate the Weemo
Javascript into a web page.  We showed how to include the Javascript
directly from the Weemo CDN (content-delivery network) using the
AppID.  We showed how to define an HTML div for holding the Weemo
video call and we showed how to tell the Weemo javascript the name of
the DOM element for holding the video.

This lesson showed how to initialize the Weemo Javascript object and
how to register event listeners for receiving and accepting a call,
and also how to reject an incoming request for a video call.  We
showed how to initiate a call to another authenticated Weemo user and
also showed how to present a pop-up box if the remote user rejects the
request for a video call.


<hr>

[ Back to [Part 2](HOWTO-part2.md) | Continue to [Part 4](HOWTO-part4.md) ]
