class Admin::HomeController < Admin::ApplicationController

  # HomePage of the Blank Application
  #
  # Root page ('/')
  #
  def index
#    @latest_items = GenericItem.consultable_by(current_user.id).latest
#    @latest_users = get_objects_list_with_search('user', 'created_at-desc', 5)
#    @latest_feeds = current_user.feed_items.latest
#    @latest_ws = get_objects_list_with_search('workspace', 'created_at-desc', 5)
#		@accordion = [@latest_items,@latest_users,@latest_feeds,@latest_ws]
    @persons = Person.find(:all, :order => "created_at DESC", :limit => 5,:conditions=>{:user_id => @current_user.id})
    @websites = Website.allowed_user_with_permission(@current_user, "website_show", 'website')
  end


  def analytics_datas
    websites = Website.allowed_user_with_permission(@current_user, "website_show", 'website')
    @websites_datas = []
    website_datas = {}
    if File.exist?("#{RAILS_ROOT}/config/customs/google_analytics.yml")
      analytic_config = YAML.load_file("#{RAILS_ROOT}/config/customs/google_analytics.yml")
      if Analytic.setup(analytic_config['sa_analytic_login'], analytic_config['sa_analytic_password'])
        begin
          websites.each do |website|
            website_url = (website && website.website_urls) ? website.website_urls.first : nil
            if !website_url.nil?
              website_datas = {}
              website_datas[:website] = website
                     
              duration = params[:d] ? params[:d] : 'year'
              profile = Garb::Account.all.first.profiles.select{|v| v.title =~ /#{website_url.name}/}.first
              unless profile.blank?
                visitor_report = Analytic.site_usage(duration, profile)
                website_datas[:visitor_number] = visitor_report.last.visits
                website_datas[:viewed_pages] = visitor_report.last.pageviews
                website_datas[:new_visits] = visitor_report.last.new_visits
                @websites_datas << website_datas
              end
            end
          end
        rescue
        end
      end
    end
    respond_to do |format|
		  format.js {render :layout => false}
		end
    
  end


  # Autocomplete on the specified model
  #
  # This function is link to an url and execute an AJAX request to get different choice
	# generated by the autocompletion algorithm.
  # You have to set a get parameter named 'object_name' to do it.
	def autocomplete_on
		conditions = if params[:name]
      ["name LIKE :name", { :name => "%#{params['name']}%"} ]
    else
      {}
    end
		@objects = params[:model_name].classify.constantize.find(:all, :conditions => conditions)
		render :text => '<ul>'+ @objects.map{ |e| '<li>' + e.name + '</li>' }.join(' ')+'</ul>'
	end
	
	def error
	  
	end

end
