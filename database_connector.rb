require 'sqlite3'
require 'active_support'
require 'active_support/core_ext/string/filters.rb'
require 'active_support/inflector.rb'

# TODO - consider making a class called "PrimaryKey" that would verify that ids are integers and that 
# =>     would allow omposite keys to be handled by this module too, instead of being treated as an edge 
# =>     case
#
# TODO - consider doing more with run_sql statements and somehow managing their return, especially
#       in class SQL calls where there is no object to attach this to

module DatabaseConnector
  
  module ClassDatabaseConnector    
    # creates a table with field names and types as provided
    #
    # field_names_and_types   - Array of the column names
    #
    # returns nothing or error message if fails
    def create_table(field_names_and_types)
      stringify = create_string_of_field_names_and_types(field_names_and_types)
      run_sql("CREATE TABLE IF NOT EXISTS #{table_name} (#{stringify});")
    end
  
    # returns a stringified version of this table, optimizied for SQL statements
    #
    # Example: 
    #           [["id", "integer"], ["name", "text"], ["grade", "integer"]]
    #        => "id INTEGER PRIMARY KEY, name TEXT, grade INTEGER" 
    #
    # field_names_and_types     - Array of Arrays of field names and their types - first Array assumed to be Primary key
    #
    # returns String
    def create_string_of_field_names_and_types(field_names_and_types)
      add_commas_to_types(field_names_and_types)
      add_primary_key_type_to_first_element(field_names_and_types)
      field_names_and_types.join(" ")
    end
    
    # utility method for create_string_of_field_names_and_types
    #
    # adds commas to the second dimension of the array
    def add_commas_to_types(field_names_and_types)
      field_names_and_types.each do |array|
        array[1] = array[1].upcase + ","
      end
    end
    
    # utility method for create_string_of_field_names_and_types
    #
    # adds commas to the second dimension of the array
    def add_primary_key_type_to_first_element(field_names_and_types)
      if !field_names_and_types.first[1].include?("PRIMARY KEY")
        field_names_and_types.first[1] = field_names_and_types.first[1].remove(/,/) + " PRIMARY KEY,"
      end
    end
    
    ####### NOTE: THIS METHOD DOES NOT WORK BECAUSE YOU CANNOT GET THE FIELDNAMES
    # # creates a new record in the table
    # #
    # # records                 - multi-dimensional Array of column names, each row representing a new record
    # #
    # # returns nothing
    # def create_new_records(records)
    # ####
    #   (0..records.length - 1).each do |x|
    #     record_as_string = add_quotes_to_string(records[x].join("', '"))
    #     CONNECTION.execute("INSERT INTO #{self.to_s.pluralize.underscore} (#{string_field_names}) VALUES (#{record_as_string});")
    #   end
    # end
    ##########
    
    # meant to be written over in each class with a valid method
    # checks before deleting if it is a foreign key in another table
    # 
    # returns Boolean
    def ok_to_delete?(id)
      true
    end
    
    # deletes the record matching the primary key
    #
    # key_id             - Integer of the value of the record you want to delete
    #
    # returns nothing
    def delete_record(id)
      if ok_to_delete?(id)
        CONNECTION.execute("DELETE FROM #{table_name} WHERE id = #{id};")
      else
        false
      end
    end

    # returns all records in database
    #
    # returns Array of a Hash of the resulting records
    def all
      self.as_objects(CONNECTION.execute("SELECT * FROM #{table_name};"))
    end
    
    
    # returns object if exists or false if not
    #
    # returns object or false
    def exists?(id)
      rec = CONNECTION.execute("SELECT * FROM #{table_name} WHERE id = #{id};").first
      if rec.nil?
        false
      else
        self.new(r)
      end
    end
    
    # retrieves a record matching the id
    #
    # returns the first object (should be only object)
    def create_from_database(id)
      rec = CONNECTION.execute("SELECT * FROM #{table_name} WHERE id = #{id};").first
      if rec.nil?
        self.new()
      else
        self.new(rec)
      end
    end
    
    # convert Hash records to Objects
    #
    # returns an Array of objects
    def as_objects(hashes)
      as_object = []
      hashes.each do |hash|
        as_object.push(self.new(hash))
      end
      as_object
    end

    # retrieves all records in this table where field name and field value have this relationship
    #
    # fieldname       - String of the field name in this table
    # field_value     - String or Integer of this field value in the table
    # relationship    - String of the relationship (ie: ==, >=, <=, !)
    #
    # returns an Array of hashes
    def where_match(field_name, field_value, relationship)
      self.as_objects(CONNECTION.execute("SELECT * FROM #{table_name} WHERE #{field_name} #{relationship} #{add_quotes_if_string(field_value)};"))
    end
    
    # returns an integer of the sum field where conditions are met
    #
    # returns an Integer or an error message
    def sum_field_where(sum_field, where_field, where_value, where_relationship)
      result = run_sql("SELECT SUM(#{sum_field}) FROM #{table_name} WHERE #{where_field} #{where_relationship} #{add_quotes_if_string(where_value)};")
      if result.is_a? Array
        result.first[0]
      else
        result
      end
    end
    
    def add_quotes_if_string(value)
      if value.is_a? String
        value = add_quotes_to_string(value)
      end
    end
    
    # returns an Array of Hashes containing the field name information for the table
    #
    # returns an Array or false if SQL error
    def get_table_info
      run_sql("PRAGMA table_info(#{table_name});")
    end
    # adds '' quotes around a string for SQL statement
    #
    # Example: 
    #
    #        text
    #     => 'text'
    # 
    # string  - String
    #
    # returns a String
    def add_quotes_to_string(string)
      string = "'#{string}'"
    end
    
    # returns a String
    #
    # returns String
    def table_name
      self.to_s.pluralize.underscore
    end
    
    # intended to run SQL string and rescues any errors
    #
    # sql_query - String of the SQL query
    #
    # returns Array of SQL result or False if SQL error
    def run_sql(sql_query)
      begin
        CONNECTION.execute(sql_query)
      rescue Exception => msg
        msg
      end
    end
    
  end
  ################################################################################
  # End of Class Module Methods
  
  
  # Extends ClassDatabaseMethods
  #
  # Parameters:
  # base: String: name of the class being included in.
  #
  # Returns:
  # nil
  #
  # State Changes:
  # None
  def self.included(base)
    base.extend ClassDatabaseConnector
  end
  
  # returns the table name - the plural of the object's class
  def table
    self.class.table_name
  end
  
  # returns an Array of the database_field_names for SQL
  def database_field_names
    attributes = instance_variables.collect{|a| a.to_s.gsub(/@/,'')}
    delete_from_array(attributes, attributes_that_should_not_be_in_database_field_names)
    attributes
  end
  
  # deletes the delete_array from array
  #
  # array         - Array that should have elements deleted from it
  # delete_array  - Array that has elements that should be deleted from array
  #
  # returns Array
  def delete_from_array(array, delete_array)
    delete_array.each do |a|
      array.delete(a)
    end
    array
  end
  
  
  # Array of the attributes names that should not be included
  #
  # Array
  def attributes_that_should_not_be_in_database_field_names
    ["id", "errors"]
  end
  
  
  #string of field names
  def string_field_names
   # database_field_names.join(', ')
    database_field_names.to_s[1...-1]
  end
  
  # returns an Array of the Foreign Key objects for this object
  #
  # returns an Array
  def foreign_keys
    vals = []
    foreign_key_fields.each do |field|
      vals << self.send(field)
    end
    vals
  end
  
  # returns an Array of Arrays, containing all possible choices for the Foreign Keys
  #
  # returns an Array of Arrays
  def foreign_key_choices
    choices = []
    foreign_keys.each do |foreign_key|
      choices << foreign_key.all_from_class
    end
    choices
  end
  
  # returns an Array of the values of these foreign_keys
  #
  # returns an Array
  def non_foreign_key_values
    vals = []
    non_foreign_key_fields.each do |field|
      vals << self.send(field)
    end
    vals
  end
  
  
  # returns an Array of foreign key fields (if any)
  #
  # returns an Array
  def foreign_key_fields
    keys = []
    database_field_names.each do |param|
      if self.send(param).is_a? ForeignKey
        keys << param
      end
    end
    keys
  end
  
  # returns an Array of all non-foreign key fields
  #
  # returns an Array
  def non_foreign_key_fields
    self.database_field_names - self.foreign_key_fields
  end
  
  
  # returns an Array of this object's parameters
  #
  # returns an Array with strings already added
  def self_values
    self_values = []
    database_field_names.each do |param| 
      self_values << get_value_including_foreign_keys(self.send(param))
    end
    self_values
  end
  
  # returns either the value or the id, if a def ForeignKey
  #
  # value - value of object
  #
  # returns value or id of ForeignKey
  def get_value_including_foreign_keys(value)
    if value.is_a? ForeignKey
      value.id
    else
      value
    end
  end
  
  
  
  
  def quoted_string_self_values
    vals = []
    self_values.each do |x|
      if x.is_a? String
        vals << add_quotes_to_string(x)
      else
        vals << x
      end
    end
    vals
  end
  
  # string of this object's parameters for SQL
  def stringify_self
    self_values.to_s[1...-1]
    #self_values.join(', ')
  end
  
  # string of the object's parameters = to their values
  # ready for a SQL Update Statement!!
  #
  # returns String
  def parameters_and_values_sql_string
    #first get an array of equal signs
    c = Array.new(self_values.length, "=")
    final_array = []
    # Then zip all three arrays together
    # Ex.  field_names  =[p1, p2, p3] 
    #      c            = ["=", "=", "="]
    #      self_values  = [1, 3, "'string'"]
    #  zip =>            [[[p1, "="], 1], [[p2, "="], 3, [[p3, "="], "'string'"]]
    zip_array = database_field_names.zip(c).zip(quoted_string_self_values)
    zip_array.each do |row|
      #             =>  [["p1 = 1"], ["p2 = 3"], ["p3 = 'string'"]]
      final_array <<  row.flatten.join(" ")
    end
    # => "p1 = 1, p2 = 3, p3 = 'string'"
    final_array.join(", ")
  end
  
  # returns a Boolean if the id does not exist in the table
  #
  # returns Boolean
  def exists?
    rec = run_sql("SELECT * FROM #{table} WHERE id = #{@id};")
    if rec.empty?
      @errors << "That id does not exist in the table."
      false
    else
      true
    end
  end
  
  
  # makes integer values an integer, makes ids blank or an integer
  #
  # last step in initialization function
  def post_initialize
    initialize_id
    initialize_fields_by_type
  end
  
  
  # initializes id to an integer or empty string if blank
  #
  # NOTE: you want to keep a blank @id an empty String because if you do not then you get SQL errors
  # an empty string for @id returns an empty Array, which can be returned as an empty Object.  Win/win
  #
  # returns @id
  def initialize_id
    if @id.blank?
      @id = ""
    else
      @id = @id.to_i
    end
  end
  
  # sets Integer types as defined by the table as an integer
  #
  # returns the database field names Array
  def initialize_fields_by_type
    database_field_names.each do |field|
      field_info = self.class.get_table_info.select {|hash| hash["name"] == field}.first
      update_field_value_to_correct_date_type(field_info, field) 
    end
  end
  
  # updates field to correct field type
  #
  # field_info    - Hash that has stored within it the correct type for this field
  # field         - Field of this object to change
  #
  # returns the field value
  def update_field_value_to_correct_date_type(field_info, field)
    if field_info["type"] == "Integer"
      self.field = self.send(field).to_i
    end
  end
  
  
  # checks if this object has been saved to the database yet
  #
  # returns Boolean
  def saved_already?
    @id != "" && @id != nil
  end
  
  # meant to be written over in each class with a valid method
  #
  # returns Boolean
  def valid?
    true
  end
  
  # creates a new record in the table for this object
  #
  # returns Integer or false
  def save_record
    if !saved_already?
      if valid?
        run_sql("INSERT INTO #{table} (#{string_field_names}) VALUES (#{stringify_self});")
        @id = CONNECTION.last_insert_row_id
      else
        false
      end
    else
      update_record
    end
  end
  
  # updates all values (except ID) in the record
  #
  # returns false if not saved
  def update_record
    
    if valid? && exists?
      query_string = "UPDATE #{table} SET #{parameters_and_values_sql_string} WHERE id = #{@id};"
      run_sql(query_string)
      @id
    else
      false
    end
  end
  
  # updates the field of one column if records meet criteria
  #
  # change_field            - String of the change field
  # change_value            - Value (Integer or String) to change in the change field
  #
  # returns fales if not saved
  def update_field(change_field, change_value)
    if change_value.is_a? String
      change_value = add_quotes_to_string(change_value)
    end
    if valid?
      run_sql("UPDATE #{table} SET #{change_field} = #{change_value} WHERE id = #{@id};")
    else
      false
    end
  end
  
  # returns the result of an array where field_name = field_value
  #
  # other_table      - String of the other table name
  # other_field_name - String of the field name of this object's ID in another table
  #
  # returns Array of a Hash of the resulting records or false if SQL error
  def where_this_id_in_another_table(other_table, other_field_name)
    run_sql("SELECT * FROM #{other_table} WHERE #{other_field_name} == #{@id};")
  end
  
  # returns the result of an array where field_name = field_value
  #
  # class_name       - Class
  # other_field_name - String of the field name of this parameter in the other table
  # this_parameter -   String or Integer of the value of this parameter for this object
  #
  # returns Array of class_name objects
  def where_this_parameter_in_another_table(class_name, this_parameter, other_field_name)
    class_name.where_match(other_field_name, this_parameter, "==")
  end
  
  # adds '' quotes around a string for SQL statement
  #
  # Example: 
  #
  #        text
  #     => 'text'
  # 
  # string  - String
  #
  # returns a String
  def add_quotes_to_string(string)
    string = "'#{string}'"
  end
  
  # intended to run SQL string and rescues any errors
  #
  # sql_query - String of the SQL query
  #
  # returns Array of SQL result or False if SQL error
  def run_sql(sql_query)
    begin
      CONNECTION.execute(sql_query)
    rescue Exception => msg
      @errors << msg
      false
    end
  end

end

