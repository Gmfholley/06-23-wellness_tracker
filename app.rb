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

get "/home" do
  @menu = home_menu
  erb :menu
end


###############################
# Show the menu for this class
get "/:class_name" do
  @class_name = menu_to_class_name[params["class_name"]]
  @menu = crud_menu(@class_name)
  erb :menu
end

########################
# Do something to this class

get "/:class_name/:action" do
  @class_name = menu_to_class_name[params["class_name"]]
  
  if params["action"] == "update" || params["action"] == "delete"
    @menu = object_menu(@class_name, params["action"])
    erb :menu
  elsif params["action"] == "show"
    @menu = object_menu(@class_name, params["action"])
    erb :menu_without_links
  elsif params["action"] == "create"
    # create an object so you can get its instance variables
    @m = @class_name.new
    # get foreign key names in this object and all possible values of the foreign key
    erb :create
  elsif params["action"] == "submit"
    @class_name = menu_to_class_name[params["class_name"]]
    @m = @class_name.new(params)
  
    if @m.save_record
      @message = "Successfully saved!"
      @menu = object_menu(@class_name, "show")
      erb :menu_without_links
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
  
  if params["action"] == "update"
    @m = @class_name.create_from_database(params["x"].to_i)
    erb :create
    
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



##############M
# Here are my menus


# returns a Home Menu object
#
# returns a Menu
def home_menu
  m = Menu.new("Where would you like to go?")
  m.add_menu_item(user_message: "Work with people", method_name: "person")
  m
end

# returns a CRUD menu
#
# returns a Menu
def crud_menu(class_name)
  class_string = class_name.to_s.downcase
  m = Menu.new("What would you like to do with #{class_string.pluralize}?")
  m.add_menu_item(user_message: "Create a new #{class_string}.", method_name: "#{class_string}/create")
  m.add_menu_item(user_message: "Show all #{class_string.pluralize}.", method_name: "#{class_string}/show")
  m.add_menu_item(user_message: "Update a #{class_string}.", method_name: "#{class_string}/update")
  m.add_menu_item(user_message: "Delete a #{class_string}.", method_name: "#{class_string}/delete")
  m
end


# returns a Menu of all the class's objects
#
# returns a Menu
def object_menu(class_name, action)
  class_string = class_name.to_s.downcase
  create_menu = Menu.new("Which #{class_string} do you want to #{action}?")
  all = class_name.all
  all.each_with_index do |object, x|
    create_menu.add_menu_item({user_message: object.to_s, method_name: "#{class_string}/#{action}/#{object.id}"})
  end
  create_menu
end

# LookUp Hash for the menu item to the class name
#
# Hash
def menu_to_class_name
  {"person" => Person}
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