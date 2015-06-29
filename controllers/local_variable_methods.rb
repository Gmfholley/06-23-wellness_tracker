module ERBVariableMethods
  # Here are methods that set ERB variables (@ variables) needed in my ERB and ERB helper files

  #####################################
  # Create ERB variables
  # sets @date_array - an Array of field names in this Class's instance variables that are dates
  # defaults to empty, but for ExerciseEvent at least it has one member
  # needed in my create erb file
  #
  # sets @date_array
  def date_array_for_this_class(class_name)
    @date_array = []
    if class_name == ExerciseEvent
      @date_array = ["date"]
    end
  end

  ######################################
  # Menu ERB variables
  # sets the variables needed to make tables out of MenuItems
  # ie...
  #   @menu - object menu for this class & action
  #   @with_links - Boolean indicating if the table should have links
  #   @html_type - the variable that stores the Method name to call to get a table
  #
  # action - String of the action to take (ie "create", "show", "update", "delete")
  # links  - Boolean indicating if it should display links around the menu items
  #
  def table_menu_local_variables(action, links)
    @menu = object_menu(@class_name, action)
    @with_links = links
    @html_type = "get_table_html_for_all_menu_items"
  end

  # sets the variables needed to make a CRUD menu for a class
  # ie...
  #   @menu - object menu for this class & action
  #   @links - Boolean indicating if the table should have links
  #   @html_type - the variable that stores the Method name to call to get a html list of CRUd options
  #
  # class_name - the Class
  #
  def home_menu_local_variables
    @menu = home_menu
    @with_links = true
    @html_type = "get_list_html_for_all_menu_items"
  end

  # sets the variables needed to make a CRUD menu for a class
  # ie...
  #   @menu - object menu for this class & action
  #   @links - Boolean indicating if the table should have links
  #   @html_type - the variable that stores the Method name to call to get a html list of CRUd options
  #
  # class_name - the Class
  #
  def crud_menu_local_variables(class_name)
    @menu = crud_menu(class_name)
    @with_links = true
    @html_type = "get_list_html_for_all_menu_items"
  end
  
  
  
  #############################
  # All ERB variables
  # sets the @class_name variable by looking up part of the url it came from
  # class names don't 1:1 match link names for length/readability reasons but are close
  # Hash called "menu_to_class_name" stores this value.  It is located in the defined_menus.rb file
  #
  # class_as_string - the url of this class name
  # 
  # sets the @class_name variable used in the erb files
  def class_variable(class_as_string)
    @class_name = menu_to_class_name[params["class_name"]]
  end
  
end