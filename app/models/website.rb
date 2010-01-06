class Website < ActiveRecord::Base

  acts_as_container
  
  has_many :website_urls, :dependent => :delete_all
  
  # Favicon of the website
  has_attached_file :favicon,
                    :url =>  "/website_files/#{self.name}/favicon/:basename.:extension",
                    :path => ":rails_root/public/website_files/#{self.name}/favicon/:basename.:extension",
                    :styles => { :default => "16x16>", :medium => "32x32>" }
  # Validation of the size of the attached file
  validates_attachment_size(:favicon, :less_than => 2.megabytes)
  
  # Layout of the website
  has_attached_file :layout,
                    :url =>    "/uploaded_files/websites/layouts/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/uploaded_files/websites/layouts/:id/:style/:basename.:extension"
  # Validation of the presence of an attached file
  # validates_attachment_presence :layout
	# Validation of the type of the attached file
  # validates_attachment_content_type :layout
	# Validation of the size of the attached file
  validates_attachment_size(:layout, :less_than => 2.megabytes)
  
  # Sitemap of the website
  has_attached_file :sitemap,
                    :url =>    "/uploaded_files/websites/sitemaps/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/uploaded_files/websites/sitemaps/:id/:style/:basename.:extension"
  # Validation of the presence of an attached file
  # validates_attachment_presence :sitemap
	# Validation of the type of the attached file
  # validates_attachment_content_type :sitemap
	# Validation of the size of the attached file
  validates_attachment_size(:sitemap, :less_than => 2.megabytes)
  
  def update_website_resource(params)
    unless params[:css].blank?
      if File.extname(params[:css].original_filename) == '.css'
        File.open(get_file_path(self.title,"stylesheets",params[:css]), "wb") {
          |f| f.write(params[:css].read)
        }
      elsif File.extname(params[:css].original_filename) == '.zip'
        self.store_assets(params[:css], 'stylesheets')
      end
    end
    unless params[:js].blank?
      if File.extname(params[:js].original_filename) == '.js'
        File.open(get_file_path(self.title,"javascripts",params[:js]), "wb") {
          |f| f.write(params[:js].read)
        }
      elsif File.extname(params[:js].original_filename) == '.zip'
        self.store_assets(params[:js], 'javascripts')
      end
    end
    unless params[:images].blank?
      if File.extname(params[:images].original_filename) == '.zip'
        self.store_assets(params[:images], 'images')
      else
        File.open(get_file_path(self.title,"images",params[:images]), "wb") {
          |f| f.write(params[:images].read)
        }
      end
    end
  end
  
  def store_assets(zip_file, dest_file)
    @upload_file_name = zip_file.original_filename
    FileUtils.makedirs("#{RAILS_ROOT}/public/website_files/#{self.title}/tmp")
    File.open("#{RAILS_ROOT}/public/website_files/#{self.title}/tmp/#{@upload_file_name}", "wb") do |f|
      f.write(zip_file.read)
    end
    zf = Zip::ZipFile.open("#{RAILS_ROOT}/public/website_files/#{self.title}/tmp/#{@upload_file_name}")
    zf.each do |entry|
      if entry.name.split('/').last.include?('.')
        fpath = File.join("#{RAILS_ROOT}/public/website_files/#{self.title}/#{dest_file}/#{entry.name.split('/').last}")
        if(File.exists?(fpath))
          File.delete(fpath)
        end
        zf.extract(entry, fpath)
      end
    end
    FileUtils.rm_rf("#{RAILS_ROOT}/public/website_files/#{self.name}/tmp")
  end

	def include_all_stylesheet_files
		res = ""
		Dir["public/website_files/#{self.title}/stylesheets/*"].collect do |uploaded_layout|
			res += "<link href='/website_files/#{self.title}/stylesheets/#{uploaded_layout.split('/')[4]}' rel='stylesheet' type='text/css' />"
		end
		return res
	end

	def include_all_javascript_files
		res = ""
		res += "<script type='text/javascript' src='/website_files/javascripts/front_application.js'></script>"
		Dir["public/front_files/#{self.title}/javascripts/*"].collect do |uploaded_layout|
			res += "<script src='/website_files/#{self.title}/javascripts/#{uploaded_layout.split('/')[4]}' type='text/javascript'></script>"
		end
	end

	# to display favicon image in site. Usage: need to call inside of <head> tag in layout
  def display_favicon
    if !self.favicon_file_name.blank?
      return "<link rel='shortcut icon' href='#{self.favicon.url}'/>"
    end
  end
  
  def website_url_names= params
		tmp = params.uniq
		self.website_urls.each do |k|
			WebsiteUrl.destroy(k.id) unless tmp.delete(k.name)
		end
		tmp.each do |website_url_name|
			self.website_urls.build(:name => website_url_name)
		end
	end
	
	private

  def get_file_path(front_name,content_type,file)
    return File.join("#{RAILS_ROOT}/public/website_files/#{front_name}/#{content_type}/", file.original_filename)
  end
  
end
