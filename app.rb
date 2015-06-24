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