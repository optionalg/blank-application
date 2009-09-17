# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	include AjaxPagination
	include GoogleTranslate

	# List f the different keys used for flash messages
  FLASH_NOTICE_KEYS = [:error, :notice, :warning]

  # Select Language
  #
  # This method is creating a select box displaying all the languages activated from the SuperAdministration
	# configuration. After a selection of a language, an Ajax request is made calling the 'change_language' method
	# defined in the Session controller
	# If there is just one language available, it is returning an empty string.
	def select_languages
		if (available_languages.size > 1)
			res = "<select name='languages' id='languages' onchange=\"new Ajax.Request('/session/change_language?locale='+this.value, {asynchronous:true, evalScripts:true}); return false;\">"
			available_languages.each do |l|
        if I18n.locale == l
          res += "<option value='#{l}' selected=true>"+I18n.t('general.language.'+l)+"</option>"
        else
          res += "<option value='#{l}'>"+I18n.t('general.language.'+l)+"</option>"
        end
			end
			res += "</select>"
		else
			res = ""
		end
		return res
	end

  # Checkboxes from list
  #
	# This method is used to generate checkboxes from a list of strings.
	#
	# Parameters :
	# - var: List of strings that will define the value to check
	# - param: String that will define the parameter that will send the checked values
	# - conf: Hash giving the actual value for the list
	# - object: String that will define also the parameter that will send the checked value (like that : object[param][] )
  #
  # Usage:
  # <tt>checkboxes_from_list(ITEMS, sa_items, @conf, "conf") </tt>
	def checkboxes_from_list(var, param, conf, object)
		res = []
		var.each do |l|
      content = '<div class="checkbox_list_horizontal">'
      content += check_box_tag(object+'['+param+']'+"[]", "#{l}", ((ref=conf[param]) ? ref.include?(l) : false), :class => "checkboxes")+' '+I18n.t('general.item.'+l)
      content += "</div>"
			res << content
    end
		return res
	end

	# Distance between two time
	#
	# This method will calculate the distance between two times
	# and generate a humanized String answer.
  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false,options = {})
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    I18n.with_options :locale => options[:locale], :scope => 'datetime.distance_in_words' do |locale|
			case distance_in_minutes
      when 0..1           then (distance_in_minutes==0) ? (locale.t :less_than_a_minute, :count => 5) : (locale.t :one_minute_ago, :count => distance_in_minutes)
      when 2..59          then locale.t :x_minutes_ago, :count => distance_in_minutes
      when 60..90         then locale.t :one_hour_ago, :count => distance_in_minutes
      when 90..1440       then locale.t :x_hours_ago, :count => (distance_in_minutes.to_f / 60.0).round
      when 1440..2160     then locale.t :one_day_ago, :count => distance_in_minutes # 1 day to 1.5 days
      when 2160..2880     then locale.t :x_days_ago, :count => (distance_in_minutes.to_f / 1440.0).round # 1.5 days to 2 days
			else
				I18n.l from_time, :format => :long1
			end
		end
  end

  def translate_text(body)
    if cookies[:tmp_lang].nil?
      cookies[:tmp_lang] = 'fr'
    elsif params[:sl]
      translator = Translator.new("#{cookies[:tmp_lang]}","#{params[:sl]}")
      cookies[:tmp_lang] = params[:sl]
      body = translator.translate(body)
    else
    end
    return body
  end


end

