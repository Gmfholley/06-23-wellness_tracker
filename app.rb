require 'date'                   # ruby's built-in date function
require 'chronic'                # gem that parses date/time
require 'sqlite3'                # gem that handles database
require 'pry'                    # gem that handles debugging
require 'sinatra'                # gem that handles html views & controller
require 'sinatra/reloader'       # reloads sinatra without restarting
require 'active_support'         # all kinds of goodies! including blank?, underscore, humanize, pluralize
require 'active_support/core_ext/string/filters.rb'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/inflector.rb'


# Database set up modules and helper classes required by models

require_relative 'foreign_key.rb'
require_relative 'database_connector.rb'
require_relative 'database_setup.rb'

# models

require_relative 'models/person.rb'
require_relative 'models/duration.rb'
require_relative 'models/intensity.rb'
require_relative 'models/exercise_type.rb'
require_relative 'models/exercise_event.rb'

# controllers

require_relative 'controllers/menu.rb'
require_relative 'controllers/menu_item.rb'
require_relative 'controllers/method_to_call.rb'

require_relative 'controllers/defined_menus.rb'
require_relative 'controllers/menu_controller.rb'
require_relative 'controllers/create_controller.rb'
require_relative 'controllers/local_variable_methods.rb'

# views are in views folder

helpers DefinedMenus, MenuController, CreateController, ERBVariableMethods

get "/home" do
  home_menu_local_variables
  erb :menu
end

###############################
# Show the menu for this class
get "/:class_name" do
  class_variable(params["class_name"])
  if @class_name.nil?
    erb :not_appearing
  else
    crud_menu_local_variables(@class_name)
    erb :menu
  end
end

########################
# Do something to this class

get "/:class_name/:action" do
  
  class_variable(params["class_name"])
  case params["action"]
  when "update", "delete"
    table_menu_local_variables(params["action"], true)
    erb :menu
  when "show"
    table_menu_local_variables(params["action"], false)
    erb :menu
  when "create"
    # create an object so you can get its instance variables
    @m = @class_name.new
    date_array_for_this_class(@class_name)
    erb :create
    
  when "submit"
    class_variable(params["class_name"])
    @m = @class_name.new(params["create_form"])
    
    if @m.save_record
      @message = "Successfully saved!"
      table_menu_local_variables("show", false)
      erb :menu
    else
      erb :create
    end
  else
    erb :not_appearing
  end
end

################################
# Do something to this object in the class

get "/:class_name/:action/:x" do
  @class_name = menu_to_class_name[params["class_name"]]
  
  case params["action"]
  when "update"
    @m = @class_name.create_from_database(params["x"].to_i)
    date_array_for_this_class(@class_name)
    erb :create
  when "delete"
    if @class_name.delete_record(params["x"].to_i)
      @message = "Successfully deleted."
    else
      @message = "This #{@class_name} cannot be deleted because it is currently used in another table."
    end
    table_menu_local_variables("show", false)
    erb :menu
  else
    erb :not_appearing
  end
  
end

get "/:not_listed" do
  erb :not_appearing
end