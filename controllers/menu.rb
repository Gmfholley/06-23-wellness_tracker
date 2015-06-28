require_relative "menu_item.rb"

class Menu
  # menu_itmes - array of menu_items
  # title - String of the title
  attr_reader :menu_items
  attr_accessor :title
  # title - String of the title
  #
  # returns self
  def initialize(title)
    @title = title
    @menu_items = []
  end
  
  # add item to menu
  #
  # args - Options Hash
  #     :key_user_returns - String of how user indicates they want this menu item
  #     :user_message     - String of the explanation of this menu item to user
  #     :do_if_chosen     - String of what to the method to call if chosen
  #
  # returns menu_items
  def add_menu_item(args)
    method = MethodToCall.new(args)
    args[:method] = method
    new_item = MenuItem.new(args)
    menu_items.push(new_item)
  end
  
  # returns the menu_item object that the user has chosen (by the item's key)
  #
  # user_input - String of the user's input
  #
  # returns the menu_item object
  def find_menu_item_chosen(user_input)
    menu_items[which_item_response(user_input)]
  end
  
  # gets user's menu prompt
  #
  # returns user's response (which is either quit or response from menu)
  def user_input_valid?(user_input)
    if user_wants_to_quit?(user_input) || user_response_in_menu?(user_input)
      true
    else
      false
    end
  end
  
  
  # returns boolean of whether user's input indicates they want to quit
  def user_wants_to_quit?(user_input)
    user_input.upcase == user_quit.upcase
  end
  
  # returns String of user prompt
  def user_pick_one_prompt
    "Select one of the menu items by number or #{user_quit} to quit."
  end
  
  # returns String of the wrong choice prompt
  def user_wrong_choice_prompt
    "Wrong choice. Please try again."
  end
  
  # returns a String of what the user can enter to Quit the menu
  def user_quit
    "Quit"
  end
  # returns the index of the menu_item chosen (based on the item_key of the menu_item)
  #
  # item_key - a String
  #
  # returns Integer
  def which_item_response(item_key)
    all_item_responses.find_index(item_key)
  end
  
  # checks whether the user has selected one of the menu item's keys
  #
  # user_input - String of the user's input
  #
  # returns boolean of whether the user response is in one of the menu item's keys
  def user_response_in_menu?(user_input)
    all_item_responses.include?(user_input)
  end
  
  # returns an Array of all menu_items key_user_reutrns
  #
  # returns Array
  def all_item_responses
    all_responses = []
    menu_items.each { |x| all_responses.push(x.key_user_returns)}
    return all_responses
  end
  
end