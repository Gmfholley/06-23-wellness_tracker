# require "../app.rb"



class Intensity
  include DatabaseConnector
  
  # duration - length
  attr_reader :id, :errors, :point_adjustment
  attr_accessor :name
  
  
  # initializes an Intensity id
  #
  # optional Hash argument
  #         name              - String of the intensity
  #         id                - Integer of the id
  #         point_adjustment  - Integer of how points should be adjusted for this intensity
  #
  # returns an instance of the object
  def initialize(args={})
    @id = args["id"]
    @name = args[:name] || args["name"]
    @point_adjustment = args[:point_adjustment] || args["point_adjustment"]
    @errors = []
    post_initialize
  end
  
  # setter method for point_adjustment to set it to an Integer
  #
  # returns point_adjustment
  
  def point_adjustment=(new_point_adjustment)
    @point_adjustment = new_point_adjustment
    post_initialize
    @point_adjustment
  end
  
  
  def to_s
    "id: #{id}\t\tname: #{name}"
  end
  
  
  # returns Array of all the location-times for this movie
  #
  # returns Array
  def exercise_events
    ExerciseEvent.where_match("intensity_id", id, "==")
  end
  
  # returns Boolean if ok to delete
  #
  # id - Integer of the id to delete
  #
  # returns Boolean
  def self.ok_to_delete?(id)
    if ExerciseEvent.where_match("intensity_id", id, "==").length > 0
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
    
    # checks the number of quarter hours
    if point_adjustment.to_s.empty?
      @errors << {message: "Point adjustment cannot be empty.", variable: "point_adjustment"}
    elsif point_adjustment.is_a? Integer
      if point_adjustment < 1
        @errors << {message: "Point adjustment must be greater than 0.", variable: "point_adjustment"}
      end
    else
      @errors << {message: "Point adjustment must be a number.", variable: "point_adjustment"}
    end
    
    @errors.empty?
  end
  
end