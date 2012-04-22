module ListsHelper

  def correct_user_or_poster
    @user = get_effected_user
    @list = List.find(params[:id])
    deny_access unless current_user?(@user) or @list.poster_id = current_user.id
  end
  

#sends list to all those you added in the creation screen
def send_lists(invitees, listhash, id_num)  
  # create a new pending event for each invitee listed by the user
  for username in invitees
    if username == current_user.name or username.empty?
      next
    end
      @user_list = List.new(listhash)
      @user_list.user_id = User.find_by_name(username).id
      @user_list.parent_id = id_num
      @user_list.save
  end
	
end


  #gets the lists for the page based on if the friend filter is on, the search string, and 
  #whose page it is currently
  def get_lists_from_search(friendfilter, search_string, user)
  	
  	@search_string = '%' + search_string + '%'
  	
    if @user == current_user
	  if friendfilter
	  	  	@lists = List.joins(:user, :items => :tags).where("(users.name LIKE ? OR lists.name LIKE ? OR items.content LIKE ? OR tags.name LIKE ?) AND (lists.poster_id = ? AND lists.user_id = ?)", @search_string, @search_string, @search_string, @search_string, current_user.id, user.id)

	  else
	  	@lists = List.joins(:user, :items => :tags).where("(users.name LIKE ? OR lists.name LIKE ? OR items.content LIKE ? OR tags.name LIKE ?) AND (lists.user_id = ?)", @search_string, @search_string, @search_string, @search_string, user.id)
	  end
	else
	  	@lists = List.joins(:user, :items => :tags).where("(users.name LIKE ? OR lists.name LIKE ? OR items.content LIKE ? OR tags.name LIKE ?) AND (lists.poster_id = ? AND lists.user_id = ?)", @search_string, @search_string, @search_string, @search_string, current_user.id, user.id)
	end  	
  	
  	return @lists.uniq
  	
  end
  
  
  
  def get_lists(friendfilter, user)

    if @user == current_user
	  if friendfilter
	    return List.where("poster_id = ? AND user_id = ?", current_user.id, user.id)
	  else
		return  List.where(:user_id => user.id)
	  end
	else
	  return List.where("poster_id = ? AND user_id = ?", current_user.id, user.id)
	end

  end


end
