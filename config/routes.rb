ActionController::Routing::Routes.draw do |map|

  # TODO: Publishing, Bookmarks, Admin related controllers: rights...

  map.root :controller => :home, :action => :index

  # Items are CMS component types
  # => Those items may be scoped to different resources
  def items_ressources(parent)
    parent.resources :articles do |articles|
      articles.resources :files
      articles.resources :images
    end
    parent.resources :sounds
    parent.resources :videos
    parent.resources :files
    parent.resources :publications
    # Publication sources are private, but need to be scoped to import publication
    # into right workspace
    parent.resources :publications_sources
  end

  # Items created outside any workspace are private or fully public.
  # Items may be acceded by a list that gives all items the user can consult.
  # => (his items, the public items, and items in workspaces he has permissions)
  items_ressources(map)

  # Items in context of workspaces
  map.resources(:workspaces) { |workspaces| items_ressources(workspaces) }
  
  # Project management
  map.resources(:projects) do |projects|
    projects.resources :meetings do |meetings|
      meetings.resources :objectives
    end
  end
  
  map.resources :users
  
end