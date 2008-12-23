# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  FLASH_NOTICE_KEYS = [:error, :notice, :warning]
	def small_item_in_list(item)
		# display all items by category
		# ...	
		content_tag :h2, item.title
		content_tag :p, item.description		
	end
        
  def flash_messages
		return unless messages = flash.keys.select{|k| FLASH_NOTICE_KEYS.include?(k)}
			formatted_messages = messages.map do |type|      
			content_tag :div, :class => type.to_s do
				message_for_item(flash[type], flash["#{type}_item".to_sym])
			end
    end
    formatted_messages.join
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message % item
    end
  end
  
  def display_top_items_tabs(page)
    html = '<ul id="tabs" class="without_img">'
    html += '<li '
    html += 'class="selected"' if (page=="comment")
    html += '>'+link_to("Les + commentés", "#")+'</li>'
    html += '<li '
    html += 'class="selected"' if (page=="note")
    html += '>'+link_to("Les mieux notés", "#")+'</li>'
    html += '<li '
    html += 'class="selected"' if (page=="view")
    html += '>'+link_to("Les + lus", "#")+'</li>'
    html += '</ul><div class="clear"></div>'
	end

	def available_items_list
		return YAML.load_file("#{RAILS_ROOT}/config/sa_config.yml")["sa_items_list"]
	end

	def available_languages_list
		return YAML.load_file("#{RAILS_ROOT}/config/sa_config.yml")["sa_languages_list"]
	end
  
end
