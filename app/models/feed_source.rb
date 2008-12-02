require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'feed-normalizer'
require 'regexps'

class FeedSource < ActiveRecord::Base
  #has_many  :feed_sources_users, :dependent => :delete_all
  
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :authors]
  	
	has_many  :feed_items , :dependent => :delete_all
	
  validates_presence_of :title, :description, :url
	#validates_uniqueness_of :title, :message => "Ce nom est déjà utilisé."
	#validates_uniqueness_of :url, :message => "Ce feed est déjà utilisé."
	validates_format_of :url, :with => /#{URL}/ix, :message=>"The format of the url is not valid."
	validate :feed_compliance
	
	def self.label
    "Flux RSS"           
  end
	
  def validate
    rss_valid?
  end
  
  def rss_valid?
    begin
      rss_content
    rescue Exception => e
      errors.add(:url, "Erreur lors de l'importation des flux, adresse invalide ?")
    end
  end

  def rss_content
		return @rss if @rss
    content = String.new # raw content of rss feed will be loaded here
    open(self.url) { |s| content = s.read }
		if !(content.blank? || content.nil?)
			if (@rss = RSS::Parser.parse(content, false))
				
			else
				p "Impossible de parser le flux "+self.name
				#redirect_to feed_contents_url
			end
		else
			p "Aucun contenu pour l'url "+self.url
			#redirect_to feed_contents_url
		end
  end
	
	def rss_content2
		return (FeedNormalizer::FeedNormalizer.parse open(self.url), :force_parser => FeedNormalizer::SimpleRssParser)
  end

  def import_latest_items
		feed = self.rss_content2
		feed.clean!
		feed.entries.each do |item|
			# Be sure that the item hasnt been imported before
			if self.feed_items.count(:conditions => { :title => item.title, :link => item.url }) <= 0
				self.feed_items.create({
					:remote_id			=> item.id,
					:title					=> item.title,
					:description		=> item.description,
					:content				=> item.content,
					:authors				=> item.authors.join(' ,'),
					:date_published => item.date_published,
					:last_updated		=> item.last_updated,
					:categories			=> item.categories.join(' ,'),
					:link           => item.url,
					:copyright			=> item.copyright })
			end
		end
	end
	
	def feed_compliance
	  begin
		  open(self.url) do |http|
      response = http.read
      result = RSS::Parser.parse(response, false)
    end
    t = true
    rescue
	    self.errors.add(:url, "The url entered is not a compliant RSS/Atom Feed") 
    end
  end
  
end
