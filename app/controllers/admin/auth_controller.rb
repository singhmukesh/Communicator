class Admin::AuthController < AdminController

  def login

    if request.post?

      admin = Admin.authenticate(params[:name], params[:password])

      if admin
        flash.now[:notice] = "Successful admin login"
        session[:admin_id] = admin.id
        redirect_to(:controller => "/users", :action => "index")
      else
        flash.now[:alert] = "Invalid admin/password combination"
      end
    end

  end

  def logout
    session[:admin_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end

end
