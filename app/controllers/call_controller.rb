class CallController < ApplicationController

  def index
    @me = current_user
    @friends = User.all.select{ |u| u != @me }
  end

  # whose presence we are interested in
  def friends
    @me = current_user
    @friends = User.all.select{ |u| u != @me }

    # see views/call/friends.json.jbuilder for field selection
    render :format => :json
  end

end
