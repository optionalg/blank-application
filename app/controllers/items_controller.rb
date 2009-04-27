class ItemsController < ApplicationController
  
  def index
		params[:item_type] ||= get_default_item_type
		@current_objects = get_items_list(params[:item_type])
		@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
		respond_to do |format|
			format.html
			format.xml { render :xml => @current_objects }
			format.json { render :json => @current_objects }
			format.atom { render :template => "#{params[:item_type]}/index.atom.builder", :layout => false }
		end
  end

  def ajax_index
		params[:item_type] ||= get_default_item_type
		@current_objects = get_items_list(params[:item_type])
		@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
    render :partial => "items/tab_list" , :layout => false
  end

	# TODO do something clean, this is too much, take a look in the view to understand ...
  def display_item_in_pop_up
    if params[:item_type] == "all"
     @current_objects = GenericItem.consultable_by(@current_user.id).articles
      #@object = Article.find(:all, :conditions =>{ :user_id => @current_user.id}, :order => "updated_at DESC" )
    else
      @current_objects = (params[:item_type].classify.constantize).find(:all, :conditions =>{ :user_id => @current_user.id}, :order => "updated_at DESC" )
    end
    render :layout => 'pop_up', :object => @current_objects
  end
end