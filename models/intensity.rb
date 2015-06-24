# require "../app.rb"



class Intensity
  include DatabaseConnector
  
  # duration - length
  attr_reader :id, :errors
  attr_accessor :name, :point_adjustment
  
  
  # initializes an Intensity id
  #
  # optional Hash argument
  #         name              - String of the rating
  #         id                - Integer of the id
  #         point_adjustment  - Integer of how points should be adjusted for this intensity
  #
  # returns an instance of the object
  def initialize(args={})
    if args["id"].blank?
      @id =  ""
    else
      @id = args["id"].to_i
    end
    @name = args[:name] || args["name"]
    @point_adjustment = (args[:point_adjustment] || args["point_adjustment"]).to_i
    @errors = []
  end
  
  def to_s
    "id: #{id}\t\tname: #{name}"
  end
  
  # TODO - uncomment this section when ExeriseEvent created
  # # returns Boolean if ok to delete
  # #
  # # id - Integer of the id to delete
  # #
  # # returns Boolean
  # def self.ok_to_delete?(id)
  #   if ExerciseEvent.where_match("intensity_id", id, "==").length > 0
  #       false
  #   else
  #       true
  #   end
  # end
  
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