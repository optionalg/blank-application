module ActsAsCommentable
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_commentable
        include ActsAsCommentable::ControllerMethods::InstanceMethods
			end
    end
    
    module InstanceMethods
      def add_comment
        if logged_in?
          current_object.comments.create(params[:comment].merge(:user => @current_user, :state => DEFAULT_COMMENT_STATE))
          current_object.comments_number = current_object.comments_number.to_i + 1
          current_object.save
          render :update do |page|
						if current_object.state == 'validated'
							page.insert_html :bottom, 'comment_list', :partial => "items/comment", :object => comment
							page.replace_html "ajax_info", :text => I18n.t('comment.add_comment.ajax_message_comment_published')
						else
							page.replace_html "ajax_info", :text => I18n.t('comment.add_comment.ajax_message_comment_submited')
						end
          end
        else
          if yacaph_validated?
            current_object.comments.create(params[:comment])
            current_object.comments_number = current_object.comments_number.to_i + 1
            current_object.save
            render :update do |page|
              page.replace_html "ajax_info", :text => I18n.t('comment.add_comment.ajax_message_comment_submited')
              page.replace_html "comment_captcha",  :partial => "items/captcha"
            end
          else
            render :update do |page|
              page.replace_html "ajax_info", :text => I18n.t('general.common_word.ajax_message_captcha_invalid')
              page.replace_html "comment_captcha",  :partial => "items/captcha"
            end
          end
        end
			end

    end
  end

	module ModelMethods

		def self.included(base)
			base.extend ClassMethods
		end

		module ClassMethods
			def acts_as_commentable
				has_many :comments, :as => :commentable, :order => 'created_at ASC', :conditions => { :state => 'validated'}, :dependent => :delete_all
				include ActsAsTaggable::ModelMethods::InstanceMethods
			end
		end

		module InstanceMethods

		end

	end



end