module DefinedMenus
  # Here are my menus


  # returns a Home Menu object
  #
  # returns a Menu
  def home_menu
    m = Menu.new("Where would you like to go?")
    m.add_menu_item(user_message: "Work with people", method_name: "person")
    m.add_menu_item(user_message: "Work with durations", method_name: "duration")
    m.add_menu_item(user_message: "Work with intensities.", method_name: "intensity")
    m.add_menu_item(user_message: "Work with exercise types.", method_name: "exercise_type")
    m.add_menu_item(user_message: "Work with exercise events.", method_name: "exercise_event")
    m
  end

  # returns a CRUD menu
  #
  # returns a Menu
  def crud_menu(class_name)
    class_string = class_name.to_s.underscore.downcase
    m = Menu.new("What would you like to do with #{class_string.humanize.downcase.pluralize}?")
    m.add_menu_item(user_message: "Create a new #{class_string.humanize.downcase}.", method_name: "#{class_string}/create")
    m.add_menu_item(user_message: "Show all #{class_string.humanize.downcase.pluralize}.", method_name: "#{class_string}/show")
    m.add_menu_item(user_message: "Update a #{class_string.humanize.downcase}.", method_name: "#{class_string}/update")
    m.add_menu_item(user_message: "Delete a #{class_string.humanize.downcase}.", method_name: "#{class_string}/delete")
    m
  end


  # returns a Menu of all the class's objects
  #
  # returns a Menu
  def object_menu(class_name, action)
    class_string = class_name.to_s.underscore.downcase
    create_menu = Menu.new("Which #{class_string.humanize.downcase} do you want to #{action}?")
    all = class_name.all
    all.each_with_index do |object, x|
      create_menu.add_menu_item({user_message: object.to_s, method_name: "#{class_string}/#{action}/#{object.id}"})
    end
    create_menu
  end


end
