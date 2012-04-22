class PostsController < ApplicationController
  layout :choose_layout
  before_filter :authenticate
  before_filter :check_if_banned
  
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
    if not params[:dashboard_id].nil?
      @dashboard_id = params[:dashboard_id]
    end
    if not params[:reply_to].nil?
      @reply_to = params[:reply_to]
    end
  end

  def edit
    @post = Post.find(params[:id])
    @dashboard = @post.dashboard

    respond_to do |format|
      format.html
      # we would like to show a lightbox if the link leading to this action added
      # class="modalbox" to the link tag
      format.js   { render :action => :redirect }
    end
  end

  def create
    @post = Post.new(params[:post])

    if not params[:post][:content].nil? and not params[:post][:content].strip.length == 0
      # the user_id of the user who created the post
      @post.user_id = current_user.id

      # make the reply private if the parent is private
      if not params[:post][:reply_to].nil?
        @parent_post = Post.find(params[:post][:reply_to])
        @post.is_private = @parent_post.is_private
      end

      if @post.save
        # the dashboard on which the post is created
        @dashboard_id = @post.dashboard_id

        @dashboard = Dashboard.find(@dashboard_id.to_i)
        @dashboard.update_attributes(:updated_at => Time.now)

        if @dashboard_id == @post.user_id
          redirect_back_or dashboard_path, notice: 'Post was successfully created.'
        else
          @friend = Dashboard.find(@dashboard_id).user
          redirect_back_or dashboard_path, notice: "Successfully created post for #{view_context.link_to(@friend.name, user_path(@friend.id))}.".html_safe
        end
      else
        redirect_back_or dashboard_path, alert: 'Posts must be 140 characters or less.'
      end
    else
      redirect_back_or dashboard_path
    end
  end

  def update
    @post = Post.find(params[:id])

    if @post.update_attributes(params[:post])
      redirect_to dashboard_user_path(@post.dashboard_id), notice: 'Post was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    redirect_to dashboard_url
  end

  def destroy_post
    destroy
  end

  def choose_layout  
    (request.xhr?) ? nil : 'application'  
  end 
end
