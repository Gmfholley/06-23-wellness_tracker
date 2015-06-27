# require "../app.rb"



class ExerciseType
  include DatabaseConnector
  
  # duration - length
  attr_reader :id, :errors, :point_base
  attr_accessor :name
  
  
  # initializes a ExerciseType id
  #
  # optional Hash argument
  #         name              - String of the rating
  #         id                - Integer of the id
  #         point_base         - Integer of the number of points this exercise type is worth
  #
  # returns an instance of the object
  def initialize(args={})
    @id = args["id"]
    @name = args[:name] || args["name"]
    @point_base = args[:point_base] || args["point_base"]
    @errors = []
    post_initialize
  end
  
  # setter method for point_base that sets it to integer if not already
  #
  # returns point_base
  def point_base=(new_point_base)
    @point_base = new_point_base
    post_initialize
    @point_base
  end
  
  
  def to_s
    "id: #{id}\t\tname: #{name}"
  end
  
  # returns Boolean if ok to delete
  #
  # id - Integer of the id to delete
  #
  # returns Boolean
  def self.ok_to_delete?(id)
    if ExerciseEvent.where_match("exercise_type_id", id, "==").length > 0
        false
    else
        true
    end
  end
  
  # returns Boolean if data is valid
  #
  # returns Boolean
  def valid?
    @errors = []
    # check thename exists and is not empty
    if name.to_s.empty?
      @errors << {message: "Name cannot be empty.", variable: "name"}
    end
    
    # checks the point base
    if point_base.to_s.empty?
      @errors << {message: "Point base cannot be empty.", variable: "point_base"}
    elsif point_base.is_a? Integer
      if point_base < 1
        @errors << {message: "Point base must be greater than 0.", variable: "point_base"}
      end
    else
      @errors << {message: "Point base must be a number.", variable: "point_base"}
    end
    
    @errors.empty?
  end
  
end
  
