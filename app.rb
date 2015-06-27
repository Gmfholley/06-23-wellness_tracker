require 'date'
require 'sqlite3'
require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'active_support'
require 'active_support/core_ext/string/filters.rb'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/inflector.rb'


require_relative 'database_connector.rb'
require_relative 'database_setup.rb'
require_relative 'foreign_key.rb'
require_relative 'views/menu.rb'
require_relative 'views/menu_item.rb'
require_relative 'views/method_to_call.rb'



require_relative 'models/person.rb'
require_relative 'models/duration.rb'
require_relative 'models/intensity.rb'
require_relative 'models/exercise_type.rb'
require_relative 'models/exercise_event.rb'



require_relative 'controllers/defined_menus.rb'

helpers DefinedMenus

get "/home" do
  @menu = home_menu
  erb :menu
end


###############################
# Show the menu for this class
get "/:class_name" do
  @class_name = menu_to_class_name[params["class_name"]]
  
  if @class_name.nil?
    erb :not_appearing
  else
  
    @menu = crud_menu(@class_name)
    erb :menu
  end
end

########################
# Do something to this class

get "/:class_name/:action" do
  
  @class_name = menu_to_class_name[params["class_name"]]
  

  case params["action"]
  when "update", "delete"
    @menu = object_menu(@class_name, params["action"])
    erb :menu
  when "show"
    @menu = object_menu(@class_name, params["action"])
    erb :menu_without_links
  when "create"
    # create an object so you can get its instance variables
    @m = @class_name.new
    @foreign_key_choices = @m.foreign_key_choices
    
    if @class_name == ExerciseEvent
      @m.date = Time.now.strftime("%m/%d/%y")
      erb :create_exercise_event
    else
      erb :create
    end
    
  when "submit"
    @class_name = menu_to_class_name[params["class_name"]]
    @m = @class_name.new(params["create_form"])
    @foreign_key_choices = @m.foreign_key_choices
  
    if @m.save_record
      @message = "Successfully saved!"
      @menu = object_menu(@class_name, "show")
      erb :menu_without_links
    else 
      if @class_name == ExerciseEvent
        erb :create_exercise_event
      else
        erb :create
      end
    end
    
  else
    erb :not_appearing
  end
end

################################
# Do something to this object in the class

get "/:class_name/:action/:x" do
  @class_name = menu_to_class_name[params["class_name"]]
  
  if params["action"] == "update"
    @m = @class_name.create_from_database(params["x"].to_i)
    @foreign_key_choices = @m.foreign_key_choices
    if @class_name == ExerciseEvent
     erb :create_exercise_event
   else 
    erb :create
  end
    
  elsif params["action"] == "delete"
    
    if @class_name.delete_record(params["x"].to_i)
      @message = "Successfully deleted."
      @menu = object_menu(@class_name, "show")
      erb :menu_without_links
    else
      @message = "This #{@class_name} was not found or was in another table.  Not deleted."
      @menu = object_menu(@class_name, "show")
      erb :menu_without_links
    end
    
  else
    erb :not_appearing
  end
  
end

get "/:not_listed" do
  erb :not_appearing
end



# LookUp Hash for the menu item to the class name
#
# Hash
def menu_to_class_name
  {"person" => Person, "duration" => Duration, "intensity" => Intensity, "exercise_type" => ExerciseType, "exercise_event" => ExerciseEvent}
end

def menu_title(class_name, action)
  if action == "show"
  end
end

def menu_title_all_but_show(class_string, action)
  "Which #{class_string} do you want to #{action}?"
end

def menu_title_show(class_string)
  "Here are all the #{class_string.pluralize}."
end