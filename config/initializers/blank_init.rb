include Configuration

# Loading the library Acts_as_item
#p "Loading ActsAsItem model methods"
require "acts_as_item/model.rb"
ActiveRecord::Base.send(:include, ActsAsItem::ModelMethods)
#p 'done'
#p "Loading ActsAsItem controller methods"
require "acts_as_item/controller.rb"
ActionController::Base.send(:include, ActsAsItem::ControllerMethods)
#p 'done'
#require "acts_as_item/helper.rb"
#ApplicationHelper.send(:include, ActsAsItem::HelperMethods)

# Defining the global variable
ITEMS = ['article', 'image', 'cms_file', 'video', 'audio', 'publication', 'feed_source', 'bookmark','newsletter','group']
LANGUAGES = ['en-US', 'fr-FR']
FEED_ITEMS_IMPORTATION_TYPES = ['bookmark', 'publication']
WS_TYPES = ['closed', 'public', 'authorized', 'archived']
RIGHT_TYPES = ['system', 'workspace']
ITEM_CATEGORIES = ['cat1', 'cat2', 'cat3']
COMMENT_STATE = ['posted', 'validated', 'rejected']
DEFAULT_COMMENT_STATE = 'posted'
LAYOUTS_AVAILABLE = ['application', 'app_fat_menu']

SEARCH_FILTERS = ['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title']

APPLICATION_ADMINS = ['paco@thinkdry.com', 'anup.nivargi@thinkdry.com',	'nagarjuna@thinkdry.com', 'sylvain@thinkdry.com',
	'david.lehureau@thinkdry.com']
APPLICATION_NAME = get_sa_config['sa_application_name']

# Setting the locales files and the default language
I18n.default_locale = "en-US"
#I18n.locale = 'fr-FR'
#I18n.default_locale = 'fr-FR'
#%w{yml rb}.each do |type|
#  I18n.load_path += Dir.glob("#{RAILS_ROOT}/app/locales/*.#{type}")
#end
LOCALES_DIRECTORY = "#{RAILS_ROOT}/config/locales"
#LOCALES_AVAILABLE = Dir["#{LOCALES_DIRECTORY}/*.{rb,yml}"].collect do |locale_file|
#  File.basename(File.basename(locale_file, ".rb"), ".yml")
#end.uniq.sort
LANGUAGES.each do |l|
	I18n.load_path << "#{LOCALES_DIRECTORY}/#{l}.yml"
end