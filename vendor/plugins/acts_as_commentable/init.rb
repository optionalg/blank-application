ActionView::Base.send                     :include, ActsAsCommentable::Helpers
ActionController::Base.send               :include, ActsAsCommentable::ControllerMethods
ActiveRecord::Base.send                   :include, ActsAsCommentable::ModelMethods

#require 'acts_as_commentable'

#%w{ models controllers helpers }.each do |dir|
#	path = File.join(File.dirname(__FILE__), 'app', dir)
#	$LOAD_PATH << path
#	ActiveSupport::Dependencies.load_paths << path
#	ActiveSupport::Dependencies.load_once_paths.delete(path)
#end