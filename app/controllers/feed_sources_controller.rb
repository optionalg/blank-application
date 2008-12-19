class FeedSourcesController < ApplicationController
  
	acts_as_ajax_validation
  acts_as_item do

		before :new do
			if params[:url]
				#if (@feed=FeedNormalizer::FeedNormalizer.parse open(params[:url]), :force_parser => FeedNormalizer::SimpleRssParser)
				if 	(@feed=FeedParser.parse(open(params[:url])))
					@current_object = FeedSource.new(
						:etag => @feed.etag,
						:version => @feed.version,
						:encoding => @feed.encoding,
						:language => @feed.feed.language,
						:title => @feed.feed.title,
						:description => @feed.feed.description,
						#:authors => @feed.authors.join(' ,'),
						:categories => @feed.feed.tags ? @feed.feed.tags.map{ |tag| tag["term"]}.to_s : nil,
						:last_updated => @feed.updated,
						:link => @feed.link,
						:url => params[:url],
						:copyright => @feed.rights,
						:ttl => @feed.feed.ttl,
						:image => @feed.image,
						:state => 'copyright'
					)
					flash[:notice] = "Ce feed a retourné ces informations, validez-les pour y souscrire."
				else
					flash[:notice] = "Ce feed n'est pas valide."
					redirect_to 'feed_sources/what_to_to'
				end
			end
		end

    after :create do 
      # After addition of a source, import the RSS into DB.
      @current_object.import_latest_items
    end
    
    before :show do
      permit "consultation of current_object"
			@feed_items = @current_object.feed_items.paginate(:page => params[:page], :per_page => 10)
    end
		
  end

	def what_to_do
		
	end
  
  def check_feed
		daurl = params[:daurl][:value]
		if daurl.blank?
			flash[:notice] = "Entrer une valeur pour le Web feed."
			redirect_to '/feed_sources/what_to_do'
		elsif (@feed=FeedSource.find(:first, :conditions => { :url => daurl, :user_id => current_user.id }))
			flash[:notice] = "Déjà souscrit"
			redirect_to feed_source_path(@feed.id)
		else
			redirect_to "/feed_sources/new?url=#{daurl}"
		end
  end
	
end