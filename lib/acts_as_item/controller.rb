module ActsAsItem
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_item &block
        include ActsAsItem::ControllerMethods::InstanceMethods
        
        make_resourceful do
          actions :all
          belongs_to :workspace

          self.instance_eval &block if block_given?
          
          before :create, :update do
            @current_object.workspace_ids = [] unless params[:workspace_ids]
          end

          after :create do
            flash[:notice] = @current_object.class.label+' '+I18n.t('item.new.flash_notice')
          end

          after :create_fails do
            flash[:error] = @current_object.class.label+' '+I18n.t('item.new.flash_error')
          end

          after :update do
            flash[:notice] = @current_object.class.label+' '+I18n.t('item.edit.flash_notice')
          end
          
           after :update_fails do
            flash[:error] = @current_object.class.label+' '+I18n.t('item.edit.flash_error')
          end

          before :new, :create do
            no_permission_redirection unless @current_object.accepts_new_for?(@current_user)
          end

          before :show, :index do
            no_permission_redirection unless @current_object.accepts_show_for?(@current_user)
          end

          before :edit, :update do
            no_permission_redirection unless @current_object.accepts_edit_for?(@current_user)
          end

          before :destroy do
            no_permission_redirection unless @current_object.accepts_destroy_for?(@current_user)
          end

					after :index do
						@current_objects = @current_objects.paginate(:per_page => 20, :page => params[:page])
					end
                    
          # Makes `current_user` as author for the current_object
          before :create do
            current_object.user_id = current_user.id
          end
					
					response_for :show do |format|
						format.html # index.html.erb
						format.xml { render :xml=>@current_object }
						format.json { render :json=>@current_object }
	        end

					response_for :index do |format|
						format.html { redirect_to(items_path(params[:controller])) }
						format.xml { render :xml=>@current_objects }
						format.json { render :json=>@current_objects }
						format.atom # index.atom.builder
	        end
					
        end
      end
    end
    
    module InstanceMethods
      def rate
        current_object.add_rating(Rating.new(:rating => params[:rated].to_i))
				# TODO : refresh the rate box ...
        render :nothing => true
      end
      
      def add_tag
        tag_name = params[:tag]['name']
        tag = Tag.find_by_name(tag_name) || Tag.create(:name => tag_name)
        current_object.taggings.create(:tag => tag)
        render :update do |page|
          page.insert_html :bottom, 'tag_list', ' ' + item_tag(tag)
        end
      end
      
      def comment
        comment = current_object.comments.create(params[:comment].merge(:user => @current_user))
        render :update do |page|
          page.insert_html :bottom, 'comment_list', :partial => "items/comment", :object => comment
        end
      end
      
      def remove_tag
        tag = current_object.taggings.find_by_tag_id(params[:tag_id].to_i)
        tag_dom_id = "tag_#{tag.tag_id}"
        tag.destroy
        render :update do |page|
          page.remove tag_dom_id
        end
      end
    end
  end
end