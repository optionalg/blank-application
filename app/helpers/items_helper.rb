module ItemsHelper

	# Item's author is allowed to remove it by Ajax action.
  def item_tag tag, editable = false
    content = tag.name
    content += link_to_remote(image_tag('icons/delete.png'),
      :url => remove_tag_item_path(@current_object, :tag_id => tag.id),
      :loading => "$('ajax_loader').show()",
      :complete => "$('ajax_loader').hide()") if editable

    content_tag :span, content, :id => "tag_#{tag.id}"
  end

  def item_editable_tag tag
    item_tag tag, true
  end

  # Ajax Action for Rating Item
  def item_rate(object, params = {})
    params = {
      :rerate => false,
  		:onRate => "function(element, info) {
  			new Ajax.Request('#{rate_item_path(object)}', {
  				parameters: info
  			})}"
  		} if params.empty?

    params_to_js_hash = '{' + params.collect { |k, v| "#{k}: #{v}" }.join(', ') + '}'
    div_id = "rating_#{object.class.to_s.underscore}_#{object.id}_#{rand(1000)}"

    content_tag(:div, nil, { :id => div_id, :class => :rating }) +
		javascript_tag(%{
			new Starbox("#{div_id}", #{object.rating}, #{params_to_js_hash});
		})
  end

  # Item Rating Locked for Preview
  def item_rate_locked(object)
    item_rate(object, :locked => true)
  end

  # Container of tags that include modal window. Contains the javascript events.
  # Please apply 'hidden' class on each child you want to be displayed on mouseover.
  def item_reactive_content_tag(tag, object, &block)
    concat \
      content_tag(tag,
        render(:partial => "items/hidden_window", :object => object) + capture(&block),
        :id           => "item_#{object.object_id}",
        :class        => 'item',
        :onmouseover  => 'this.addClassName("over")',
        :onmouseout   => 'this.removeClassName("over")',
        :onclick      => "window.location.href = '#{item_path(object)}'"),
      block.binding
  end


	# Define the common fields of the form of an item
  def form_for_item(object, title = '', &block)
		concat(render(:partial => "items/form", :locals => { :block => block, :title => title }), block.binding)
  end

	# Define the common information of the index of an item
#	def index_for_item
#		render(:partial => "items/index", :object => @current_objects)
#	end

	# Define the common information of the show of an item
	def item_show(parameters, &block)
    concat\
      render( :partial => "items/show",
              :locals => {  :object => parameters[:object],
                            :title => parameters[:title],
                            :block => block                 } ),
      block.binding
  end
  
  # Define the common information of the show of an item
#  def item_preview(parameters, &block)
#    concat\
#      render( :partial => "items/preview",
#              :locals => {  :object => parameters[:object],
#                            :title => parameters[:title],
#                            :block => block                 } ),
#      block.binding
#  end

	# Form part for FCKEditor field
	def advanced_editor_on(object, attribute)
    '<script type="text/javascript" src="/fckeditor/fckeditor.js"></script>' +
    javascript_tag(%{
        var oFCKeditor = new FCKeditor('#{object.class.to_s.underscore}_#{attribute}', '730px', '350px') ;
        oFCKeditor.BasePath = "/fckeditor/" ;
				oFCKeditor.Config['ImageUploadURL'] = "/fckuploads?item_type=#{object.class}&id=#{object.new_record? ? current_user.login+'_'+current_user.id.to_s : object.id}&type=Image";
        oFCKeditor.Config['DefaultLanguage'] = '#{I18n.locale.split('-')[0]}' ;
        oFCKeditor.ReplaceTextarea() ;
        
		})
  end

  # Footer of each item form. Status, comments, tags...
  def item_status_fields(form, item)
    render :partial => "items/status", :locals => { :f => form, :item => item }
  end

	# Form part for the categories
  def item_category_fields(form, item)
    render :partial => "items/category", :locals => { :f => form, :item => item }
	end

	# Form part managing keywords
	def item_keywords_fields(form, item)
    render :partial => "items/keywords_fields", :locals => { :f => form, :item => item }
	end

	# Displays the tabs link to items
  def display_tabs_items_list(item_type, items_list, ajax_url)
		item_types = get_allowed_item_types(current_workspace)
		item_type ||= item_types.first.to_s.pluralize
    content = String.new
		#raise item_types.inspect
		if item_type.blank?
			return I18n.t('item.common_word.no_item_types')
		else
			item_types.map{ |item| item.camelize }.each do |item_model|
     
        # each li got a different content
        li_content = String.new
        
				url = ajax_items_path(item_model.classify.constantize)
				item_page = item_model.underscore.pluralize
				options = {}
				options[:class] = 'selected' if (item_type == item_page)
				options[:id] = item_model.underscore

        tip_option = {}
        tip_option[:id] = "tip_" + item_model.underscore
        tip_option[:style] = "display:none;"
        tip_option[:class] = "tipTitle"
        
        li_content += link_to_remote(image_tag(item_model.classify.constantize.icon_48),:method=>:get, :update => "object-list", :url => url, :before => "selectItemTab('" + item_model.underscore + "')")
        li_content += content_tag(:div, item_model.classify.constantize.label , tip_option)
        li_content += "<script type='text/javascript'>
                      //<![CDATA[
                        new Tip('" + item_model.underscore + "',  $('tip_" + item_model.underscore + "'),
                            { effect: 'appear',
                              duration: 1,
                              delay:0,
                              hook: { target: 'topMiddle', tip: 'bottomMiddle' },
                              hideOn: { element: 'tip', event: 'mouseout' },
                              stem: 'bottomMiddle',
                              hideOthers: 'true',
                              hideAfter: 1,
                              width: 'auto',
                              border: 1,
                              offset: { x: 0, y: 3 },
                              radius: 0
                            });
                      //]]>
                    </script>"
				content += content_tag(:li,	li_content,	options)
			end
			return content_tag(:ul, content, :id => :tabs) + display_items_list(items_list, ajax_url)
		end
	end

  # Displays the list of items
	def display_items_list(items_list, ajax_url, partial_used='items/items_list')
		if items_list.first

	    content = render :partial => partial_used, :locals => { :ajax_url => ajax_url }
      content_tag(:div, content, :id => "object-list")
		else
			render :text => "<br /><br />"+I18n.t('item.common_word.list_empty')
		end
	end

	# Displays the list of items
  def display_item_in_list(items_list, partial_used='items/item_in_list')
		@i = 0
	  render :partial => partial_used, :collection => items_list
  end

  # Display Item in List for Editor
	def display_item_in_list_for_editor
		display_item_list('items/item_in_list_for_editor')
	end

  # Classify Bar for Ordering, Filtering Items
	def display_classify_bar(ordering_fields_list, ajax_url, refreshed_div, partial_used='items/classify_bar')
		render :partial => partial_used, :locals => {
				:ordering_fields_list => ordering_fields_list,
				:ajax_url => ajax_url,
				:refreshed_div => refreshed_div
		}
	end

  # Create Item Path for Ajax Calls
  def get_ajax_item_path(item_type)
    item_type ||=  get_allowed_item_types(current_workspace).first.pluralize
    url = current_workspace ? ajax_items_path(item_type) +"&page=" : ajax_items_path(item_type) +"?page="
    return url
  end

  # Safe Url for Classify Bar
	def safe_url(url, params)
		# TODO generic allowing to replace params in url
		# trick, work just for classify_bar case
		prev_params = (a=request.url.split('?')).size > 1 ? '?'+a.last : ''
		#raise request.url.split('?').size.inspect
		return (url+prev_params).split(params.first.split('=').first).first + ((url+prev_params).include?('?') ? '&' : '?') +params.join('&')
	end

  # Render Specific Partial according to Item Type passed
  def get_specific_partial(item_type, partial, object)
     if File.exists?(RAILS_ROOT+'/app/views/'+object.class.to_s.downcase.pluralize.underscore+"/_#{partial}.html.erb")
			 render :partial => "#{object.class.to_s.downcase.pluralize.underscore}/#{partial}", :object => object
     else
       render :nothing => true
     end
  end
	
end