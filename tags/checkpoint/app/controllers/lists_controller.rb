class ListsController < ApplicationController

  def index
    @lists = List.all
	@user = get_user
	
	if @user == current_user
		@lists = List.where(:user_id => @user.id)
	else
		@lists = List.where("poster_id = ? AND user_id = ?", current_user.id, @user.id)
	end

  end

  def show
  	@user = get_user
    @list = List.find(params[:id])
    @items = Item.where(:list_id => @list.id)
  end


  def new
  	@user = get_user
    @list = List.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @list }
    end
  end

  def edit
    @list = List.find(params[:id])
    @item = Item.new
    @items = Item.where(:list_id => @list.id)
    @user = get_user
  end

  def create
    @list = List.new(params[:list])

    respond_to do |format|
      if @list.save
        format.html { redirect_to edit_user_list_path(User.find(@list.user_id), @list), notice: 'List was successfully created.' }
        format.json { render json: @list, status: :created, location: @list }
      else
        format.html { render action: "new" }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @list = List.find(params[:id])

    respond_to do |format|
      if @list.update_attributes(params[:list])
        format.html { redirect_to @list, notice: 'List was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @list = List.find(params[:id])
    @list.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :ok }
    end
  end
  
  def destroy_list
    destroy
  end

  private  
  
  def get_user 
   if params[:user_id].nil?
	  current_user
    else
      User.find(params[:user_id])
    end
  end    
   
end
