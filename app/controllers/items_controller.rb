class ItemsController < ApplicationController

  # Action rendering the content tabs page for items
  #
	# This action is retrieving the items list of the type given by the 'item_type' parameters (HTTP parameters).
	# If this prameters is not given it will select automatically the first type available.
	# It is so rendering the 'items/index.html.erb' view template.
	#
	# Usage URL :
	# - /content
	# - /content?item_type=article
  def index
		params[:item_type] ||= get_allowed_item_types(current_workspace).first.pluralize
		@current_objects = get_items_list(params[:item_type], current_workspace)
		@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
		respond_to do |format|
			format.html
			format.xml { render :xml => @current_objects }
			format.json { render :json => @current_objects }
			format.atom { render :template => "items/index.atom.builder", :layout => false }
		end
  end

  # Ajax action managing pagination for items tabs
  #
	# This function will refresh the tabs of the specified item type inside the content tabs list.
	# It is linked to an url and managed an AJAX request.
	#
  # Usage URL:
  # - /ajax_content
	# - /ajax_content?item_type=article
  #
  def ajax_index
		params[:item_type] ||= get_allowed_item_types(current_workspace).first.pluralize
		@current_objects = get_items_list(params[:item_type], current_workspace)
		@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
    @i = 0
		render :partial => "items/items_list", :layout => false, :locals => { :ajax_url => current_workspace ? "/workspaces/#{current_workspace.id}/ajax_content/"+params[:item_type] : "/ajax_content/#{params[:item_type]}" }
  end

  # Action displaying items of the specified FCKeditor action ('selected_item' parameters)
  #
	# This function will generate the list of the specified item type ('item_type' parameters),
	# and with other parameters like the workspace selected, in order to filter the results.
	#
  # Usage URL :
  # - '/display_content_list/:selected_item
  def display_item_in_pop_up
    @workspace = (params[:workspace_id] && !params[:workspace_id].blank?) ? Workspace.find(params[:workspace_id]) : nil
		@workspaces = current_user.has_system_role('superadmin') ? Workspace.all : current_user.workspaces
		if params[:selected_item] == 'all'
			@selected_item_types = get_fcke_item_types
			@item_types = (item_types_allowed_to(current_user, 'show', @workspace)&@selected_item_types)
			params[:item_type] ||= @item_types.first
      if params[:item_type]
        @current_objects = get_items_list(params[:item_type], @workspace)
      else
        render :text => "No item types available for your profil."
        return
      end
		elsif (params[:selected_item] == 'images' || params[:selected_item] == 'videos')
			@selected_item_types = [params[:selected_item].to_s.singularize]
			params[:item_type] ||= @selected_item_types.first
			if !params[:item_type].include?('fcke')
				@current_objects = get_items_list(params[:selected_item], @workspace)
			else
				@fcke_objects = []
				if session[:fck_item_type] != 'Page'
					Dir["public/uploaded_files/#{session[:fck_item_type].singularize.downcase}/#{session[:fck_item_id]}/fck_#{params[:selected_item]}/*.*"].collect do |uploaded_image|
						@fcke_objects << { :name => uploaded_image.split('/')[5], :url => root_url+uploaded_image.split('public/')[1] }
					end
				else
					object = session[:fck_item_type].classify.constantize.find(session[:fck_item_id])
					workspace = object.workspaces.delete_if{ |e| e.state == 'private' }.first
					Dir["public/uploaded_files/workspace/#{workspace.id}/fck_#{params[:selected_item]}/*.*"].collect do |uploaded_image|
						@fcke_objects << { :name => uploaded_image.split('/')[5], :url => root_url+uploaded_image.split('public/')[1] }
					end
				end
			end
		else
				###
		end
		#if @current_objects.first
			render :layout => 'pop_up', :object => @current_objects
		#else
		#	render :update do |page|
		#		page.replace_html('abc', :text => 'No results for these criterions.')
		#	end
		#end
  end
end