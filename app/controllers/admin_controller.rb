class AdminController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authorize, :except => :login
  helper_method :current_admin, :admin_signed_in?

  def authorize
    unless Admin.find_by_id(session[:admin_id])
      flash[:notice] = "Admin: Please log in"
      redirect_to :controller => 'admin/auth', :action => 'login'
    end
  end

  def current_admin
    @current_admin ||= Admin.find_by_id(session[:admin_id])
  end

  def admin_signed_in?
    current_admin != nil
  end
    

end
