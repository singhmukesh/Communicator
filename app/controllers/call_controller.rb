class CallController < ApplicationController

  def index
    @me = current_user
    @friends = User.all.select{ |u| u != @me }
  end

end
