require 'date'
require 'sqlite3'
require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'active_support'
require 'active_support/core_ext/string/filters.rb'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/inflector.rb'


require_relative 'foreign_key.rb'
require_relative 'database_connector.rb'
require_relative 'database_setup.rb'



require_relative 'controllers/menu.rb'
require_relative 'controllers/menu_item.rb'
require_relative 'controllers/method_to_call.rb'



require_relative 'models/person.rb'
require_relative 'models/duration.rb'
require_relative 'models/intensity.rb'
require_relative 'models/exercise_type.rb'
require_relative 'models/exercise_event.rb'



require_relative 'controllers/defined_menus.rb'
require_relative 'controllers/menu_controller.rb'
require_relative 'controllers/create_controller.rb'


helpers DefinedMenus, MenuController, CreateController

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
    crud_menu_local_variables
    erb :menu
  end
end

########################
# Do something to this class

get "/:class_name/:action" do
  
  class_variable(params["class_name"])
  case params["action"]
  when "update", "delete"
    @menu = object_menu(@class_name, params["action"])
    @with_links = true
    @html_type = "get_table_html_for_all_menu_items"
    erb :menu
  when "show"
    @menu = object_menu(@class_name, params["action"])
    @links = false
    @html_type = "get_table_html_for_all_menu_items"
    erb :menu
  when "create"
    # create an object so you can get its instance variables
    @m = @class_name.new
    @date_array = []
    if @class_name == ExerciseEvent
      @date_array = ["date"]
    end
    erb :create
  when "submit"
    class_variable(params["class_name"])
    
    
    @m = @class_name.new(params["create_form"])
    @foreign_key_choices = @m.foreign_key_choices
  
    if @m.save_record
      @message = "Successfully saved!"
      @menu = object_menu(@class_name, "show")
      @links = false
      @html_type = "get_table_html_for_all_menu_items"
      erb :menu
    else 
      @date_array = []
      if @class_name == ExerciseEvent
        @date_array = ["date"]
      end
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
    @date_array = []
    if @class_name == ExerciseEvent
      @date_array = ["date"]
    end
    erb :create
  when "delete"
    if @class_name.delete_record(params["x"].to_i)
      @message = "Successfully deleted."
      @menu = object_menu(@class_name, "show")
      @links = false
      @html_type = "get_table_html_for_all_menu_items"
      erb :menu
    else
      @message = "This #{@class_name} cannot be deleted because it is currently used in another table."
      @menu = object_menu(@class_name, "show")
      @links = false
      @html_type = "get_table_html_for_all_menu_items"
      erb :menu
    end
  else
    erb :not_appearing
  end
  
end

get "/:not_listed" do
  erb :not_appearing
end


def home_menu_local_variables
  @menu = home_menu
  @with_links = true
  @html_type = "get_list_html_for_all_menu_items"
end

def crud_menu_local_variables
  @menu = crud_menu(@class_name)
  @with_links = true
  @html_type = "get_list_html_for_all_menu_items"
end

def class_variable(class_as_string)
  @class_name = menu_to_class_name[params["class_name"]]
end