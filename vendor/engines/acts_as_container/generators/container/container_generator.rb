class ContainerGenerator < Rails::Generator::NamedBase

	attr_reader   :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_plural_name
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name

	def initialize(runtime_args, runtime_options = {})
    super
		base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@name.pluralize)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
	end

  def manifest
    record do |m|

			# Check for class naming collisions.
			m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_path, "#{class_name}")

			# Migration
			m.migration_template('migration.rb', 'db/migrate', :assigns => {
            :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}", 
            :attributes => attributes},
            :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}")
					
			# Model generation
			m.directory(File.join('app/models', class_path)) # Create directory if it is not existing
			m.template('model.rb', File.join('app/models', class_path, "#{file_name}.rb"))
			m.template('items_model.rb', File.join('app/models', class_path, "items_#{file_name}.rb"))
			
			# Controller generation
			m.directory(File.join('app/controllers', controller_class_path)) # Create directory if it is not existing
			m.template('controller.rb', File.join('app/controllers/admin', controller_class_path, "#{controller_file_name}_controller.rb"))
			
			# Helper generation
#      m.directory(File.join('app/helpers', controller_class_path))
#			m.template('helper.rb', File.join('app/helpers', controller_class_path, "#{controller_file_name}_helper.rb"))

			# Tests generation
#      m.directory(File.join('test/functional', controller_class_path))
#			m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
#      m.directory(File.join('test/unit', class_path))
#			m.template('unit_test.rb',       File.join('test/unit', class_path, "#{file_name}_test.rb"))
#      m.directory(File.join('test/fixtures', class_path))
#			m.template('fixtures.yml',       File.join('test/fixtures', "#{table_name}.yml"))

			# Views generation
			m.directory(File.join('app/views/admin', controller_class_path, controller_file_name)) # Create directory if it is not existing
			for action in %w{ show _form }
				m.file("views/#{action}.html.erb", File.join('app/views/admin', controller_class_path, controller_file_name, "#{action}.html.erb"))
			end

		end

	end
		
	protected

  def banner
    "Usage: #{$0} container ModelName field:type, field:type, ..."
  end

	def model_name
    class_name.demodulize
  end

end

