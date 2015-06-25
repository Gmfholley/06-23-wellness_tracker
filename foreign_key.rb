require_relative 'database_connector.rb'

class ForeignKey
  
  attr_reader :class_name, :errors
  attr_accessor :id
  
  def initialize(args={})
    @id = args["id"] || args[:id]
    @id = @id.to_i
    @class_name = args["class_name"] || args[:class_name]
    @errors = []
  end
  
  # returns the first object coresponding to this id in class_name's table
  #
  # returns an object
  def get_object
    class_name.create_from_database(id)
  end
  
  
  # fetches all objects from the foreign class as an Array
  #
  # returns an Array
  def all_from_class
    begin
      class_name.all
    rescue
      @errors << {message: "Unable to find this class in the database.", variable: "class_name"}
      []
    end  
  end
  
  
  # returns an Array of possible values of this id
  #
  # returns an Array
  def possible_values
    all_objects = all_from_class
    values = []
    all_objects.each do |obj|
      values << obj.send("id")
    end
    values
  end
  
  # returns boolean if there are no errors
  #
  # returns Boolean
  def valid?
    @errors = []
    if id.blank?
      @errors << {message: "#{class_name} id cannot be blank.", variable: "id"}
    elsif !possible_values.include?(id)
      @errors << {message: "#{class_name} id must be included in the table.", variable: "id"}
    end
    
    if class_name.blank?
      @errors << {message: "Class cannot be blank.", variable: "class"}
    end
    
    @errors.empty?
  end
end