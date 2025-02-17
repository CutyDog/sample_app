class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers, :rss_feed]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.json { render json: @users}
    end  
  end  
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    @microposts_all = @user.microposts
    #@fake = Faker::Book.title
    respond_to do |format|
      format.html
      format.json { render json: {user: @user, microposts: @microposts_all} }
    end  
    redirect_to root_url and return unless @user.activated?
  end 
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      flash[:danger] = "It failed to Sign Up"
      render 'new'
    end  
  end  
  
  def edit
  end  
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end 
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end 
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    @users_all = @user.following
    respond_to do |format|
      format.html { render 'show_follow' }
      format.json { render json: @users_all }
    end  
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    @users_all = @user.followers
    respond_to do |format|
      format.html { render 'show_follow' }
      format.json { render json: @users_all }  
    end    
  end  
  
  def rss_micropost 
    @user = User.find(params[:id])
    @post_rss = @user.microposts
    # respond_to do |format|
    #   format.html
    #   format.atom
    #   format.rss
    # end  
  end  
  
  def rss_feed
    @user = current_user
    @feed_rss = @user.feed
  end 
  
  def search
    @keyword = params[:keyword]
    @user_names = (@keyword ? User.where('name like ?', "%#{@keyword}%") : User.all)
  end  
  
  private  
  
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end  
  
    # beforeアクション
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end  
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end  
    
    def autocomplete_params
      params.permit(:name)
    end
end
