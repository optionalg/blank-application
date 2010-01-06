class Admin::WebsitesController < Admin::ApplicationController

	# Mixin setting the permission for that controller (see lib/acts_as_authorizable.rb for more)
	acts_as_authorizable(
		:actions_permissions_links => {
      'new' => 'new',
      'create' => 'new',
      'edit' => 'edit',
      'update' => 'edit',
      'show' => 'show',
      'rate' => 'rate',
      'add_comment' => 'comment',
      'destroy' => 'destroy',
      'add_new_user' => 'edit'
    },
		:skip_logging_actions => [:get_website, :load_site, :form_management, :load_news])

  acts_as_container do
    
    before :edit do
      @pages = current_user.private_workspace.pages
    end
    
    after :update do
      if params[:website_files]
        @current_object.update_website_resource(params[:website_files])
      end
    end
    
  end
end
