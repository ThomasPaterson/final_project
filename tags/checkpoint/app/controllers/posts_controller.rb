class PostsController < ApplicationController

  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def edit
    @post = Post.find(params[:id])
  end

  def create
    @post = Post.new(params[:post])
    @post.user_id = current_user.id
    if @post.save
      @dashboard_id = @post.dashboard_id

      @dashboard = Dashboard.find(@dashboard_id)
      @dashboard.update_attributes(:updated_at => Time.now)

      if @dashboard_id == @post.user_id
        redirect_to dashboard_path, notice: 'Post was successfully created.'
      else
        redirect_to dashboard_user_path(@dashboard_id), notice: 'Post was successfully created.'
      end
    else
      redirect_to dashboard_path, alert: 'Posts must be 140 characters or less.'
    end
  end

  def update
    @post = Post.find(params[:id])

    if @post.update_attributes(params[:post])
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
  end
end
