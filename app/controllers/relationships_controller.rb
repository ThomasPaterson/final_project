class RelationshipsController < ApplicationController
  before_filter :authenticate
  
  #creates two relationships, and confirms for the one inviting
  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow_confirm!(@user)
    @user.follow!(current_user)
    redirect_to :back
  end

  #destroys both relationships
  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    @user.unfollow!(current_user)
    redirect_to :back
  end
  
  def update
    @rel = Relationship.find(params[:id])

    if @rel.update_attribute(:confirmed, true)
      redirect_to :back, notice: 'Friend request confirmed.'
    else
      redirect_to :back, notice: 'Problem with confirmation.'
    end
  end
  
end