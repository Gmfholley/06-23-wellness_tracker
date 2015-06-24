require 'sqlite3'
require 'active_support'
require 'active_support/core_ext/string/filters.rb'
require 'active_support/inflector.rb'

# TODO - consider making a class called "PrimaryKey" that would verify that ids are integers and that 
# =>     would allow omposite keys to be handled by this module too, instead of being treated as an edge 
# =>     case
#

module DatabaseConnector
  
  module ClassDatabaseConnector    
    # connects to the database
    #
    # database_name    - String representing the database name (and relative path)
    #
    # returns Object representing the database CONNECTION 
    # def connection_to_database(database_name)
    #   CONNECTION = SQLite3::Database.new(database_name)
    #   CONNECTION.results_as_hash = true
    # end

    # creates a table with field names and types as provided
    #
    # field_names_and_types   - Array of the column names
    #
    # returns nothing
    def create_table(field_names_and_types)
      stringify = create_string_of_field_names_and_types(field_names_and_types)
      CONNECTION.execute("CREATE TABLE IF NOT EXISTS #{self.to_s.pluralize.underscore} (#{stringify});")
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
      field_names_and_types.each do |array|
        array[1] = array[1].upcase + ","
      end
      if !field_names_and_types.first[1].include?("PRIMARY KEY")
        field_names_and_types.first[1] = field_names_and_types.first[1].remove(/,/) + " PRIMARY KEY,"
      end
      field_names_and_types.join(" ")
    end
  
    ####### NOTE: THIS METHOD DOE SNOT WORK BECAUSE YOU CANNOT GET THE FIELDNAMES
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
        CONNECTION.execute("DELETE FROM #{self.to_s.pluralize.underscore} WHERE id = #{id};")
      else
        false
      end
    end

    # returns all records in database
    #
    # returns Array of a Hash of the resulting records
    def all
      self.as_objects(CONNECTION.execute("SELECT * FROM #{self.to_s.pluralize.underscore};"))
    end
    
    
    # returns object if exists or false if not
    #
    # returns object or false
    def exists?(id)
      rec = CONNECTION.execute("SELECT * FROM #{self.to_s.pluralize.underscore} WHERE id = #{id};").first
      if rec.nil?
        false
      else
        self.new(r)
      end
    end
    
    
    # retrieves a record matching the id
    #
    # returns this object's Hash
    def create_from_database(id)
      rec = CONNECTION.execute("SELECT * FROM #{self.to_s.pluralize.underscore} WHERE id = #{id};").first
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
      if field_value.is_a? String
        field_value = add_quotes_to_string(field_value)
      end
      self.as_objects(CONNECTION.execute("SELECT * FROM #{self.to_s.pluralize.underscore} WHERE #{field_name} #{relationship} #{field_value};"))
    end
    
    # returns an Array of Hashes containing the field name information for the table
    #
    # returns an Array
    def get_table_info
      CONNECTION.execute("PRAGMA table_info(#{self.to_s.pluralize.underscore});")
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
    self.class.to_s.pluralize.underscore
  end
  
  # returns an Array of the database_field_names for SQL
  def database_field_names
    attributes = instance_variables.collect{|a| a.to_s.gsub(/@/,'')}
    attributes.delete("id")
    attributes.delete("errors")
    attributes
    # attributes = []
    # instance_variables.each do |i|
    #   unless i == "@id".to_sym
    #     attributes << i.to_s.delete("@")
    #   end
    # end
    # attributes
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
    foreign_key_choices = []
    foreign_keys.each do |foreign_key|
      foreign_key_choices << foreign_key.all_from_class
    end
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
      val = self.send(param)
      if val.is_a? ForeignKey
        self_values << val.id
      else
        self_values << val
      end
    end
    self_values
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
    rec = CONNECTION.execute("SELECT * FROM #{table} WHERE id = #{@id};").first
    if rec.nil?
      @errors << "That id does not exist in the table."
      false
    else
      true
    end
  end
  
  # checks if this object has been saved to the database yet
  #
  # returns Boolean
  def saved_already?
    @id != ""
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
        CONNECTION.execute("INSERT INTO #{table} (#{string_field_names}) VALUES (#{stringify_self});")
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
      CONNECTION.execute(query_string)
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
      CONNECTION.execute("UPDATE #{table} SET #{change_field} = #{change_value} WHERE id = #{@id};")
    else
      false
    end
  end
  
  # returns the result of an array where field_name = field_value
  #
  # other_table      - String of the other table name
  # other_field_name - String of the field name of this object's ID in another table
  #
  # returns Array of a Hash of the resulting records
  def where_this_id_in_another_table(other_table, other_field_name)
    CONNECTION.execute("SELECT * FROM #{other_table} WHERE #{other_field_name} == #{@id};")
  end
  
  # returns the result of an array where field_name = field_value
  #
  # other_table      - String of the other table name
  # other_field_name - String of the field name of this parameter in the other table
  # this_parameter -   String or Integer of the value of this parameter for this object
  #
  # returns Array of a Hash of the resulting records
  def where_this_parameter_in_another_table(other_table, this_parameter, other_field_name)
    if this_parameter.is_a? String
      this_paramter = add_quotes_to_string(this_parameter)
    end
    CONNECTION.execute("SELECT * FROM #{other_table} WHERE #{other_field_name} == #{this_parameter};")
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

end

