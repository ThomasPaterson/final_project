class ListsController < ApplicationController
  layout :choose_layout
  before_filter :authenticate
  before_filter :correct_user_or_friend, :except => [:create]
  before_filter :correct_user_or_poster, :only => [:destroy]
  before_filter :check_if_banned
  
  def index
  	@title = "All Lists"
    @lists = List.all
  	@user = get_user
  	@search = List.new
	
    #select the current filter based on the url to current page
  	@url = request.fullpath
  	@friendfilter = check_filter(@url, "friendfilter=true")
	
  	#if there isn't a search right now, get list based on page, friendfilter
  	if params[:list].nil?
  	  @lists = get_lists(@friendfilter, @user)
    else
      if params[:list][:name] == ''
      	@lists = get_lists(@friendfilter, @user)
      else
      	@search_string = params[:list][:name]
      	@lists = get_lists_from_search(@friendfilter, params[:list][:name], @user)
  	  end
    end
    
    if @lists.count > 0
      @lists = @lists.paginate(:page => params[:page], :per_page => 10)
    end

  end

  def show
  	@title = "View List"
  	@user = get_user
    @list = List.find(params[:id])
    @items = Item.where("list_id = ? OR list_id = ?", @list.id, @list.parent_id)
  end

  
  def new
  	@title = "Create a List"
  	@user = get_user
    @list = List.new
    @item = Item.new
    @items = Item.where("list_id = ? OR list_id = ?", @list.id, @list.parent_id)
    @friends = @user.following
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @list }
    end
  end
 
  #page for adding items to the list
  def edit
  	@title = "Edit List"
    @list = List.find(params[:id])
    @item = Item.new
    @items = Item.where("list_id = ? OR list_id = ?", @list.id, @list.parent_id)
    @user = get_user
    @friends = @user.following
  end
  
  #goes to the edit page to have items added to it
  #also creates child lists, that have their items point to the parent lists items
  def create
    @list = List.new(params[:list])
    
    respond_to do |format|
      if @list.save
      	# removes duplicate invitees so only one invite is created per unique user selected
    	@invitees = Array.new(params[:invitee]).uniq
		send_lists(@invitees, params[:list], @list.id)
		
        format.html { redirect_to edit_user_list_path(User.find(@list.user_id), @list) }
      else
        format.html { redirect_to :back, notice: 'Error creating list.'}
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
   
  def choose_layout  
    (request.xhr?) ? nil : 'application'  
  end 
end
