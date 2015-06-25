# require "../app.rb"



class ExerciseType
  include DatabaseConnector
  
  # duration - length
  attr_reader :id, :errors
  attr_accessor :name, :point_base
  
  
  # initializes a ExerciseType id
  #
  # optional Hash argument
  #         name              - String of the rating
  #         id                - Integer of the id
  #         point_base         - Integer of the number of points this exercise type is worth
  #
  # returns an instance of the object
  def initialize(args={})
    if args["id"].blank?
      @id =  ""
    else
      @id = args["id"].to_i
    end
    @name = args[:name] || args["name"]
    @point_base = (args[:point_base] || args["point_base"]).to_i
    @errors = []
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

# This was just awesome code I wrote to put the values into ExerciseType
#
# (1..72).each do |x|
#   case
#   when x % 4 == 1
#     s = " and fifteen minutes"
#   when x % 4 == 2
#     s = " and a half"
#   when x % 4 == 3
#     s = " and 45 minutes"
#   when x % 4 == 0
#     s = ""
#   end
#
#   case
#   when x < 4
#     l = ExerciseType.new(name: s, num_quarter_hours: x)
#     l.save_record
#   when x >=4 && x < 8
#     l = ExerciseType.new(name: "1 hour#{s}", num_quarter_hours: x)
#     l.save_record
#   when x >= 8
#     y = (x/4).to_i
#     l = ExerciseType.new(name: "#{y} hours#{s}", num_quarter_hours: x )
#     l.save_record
#   end
# end
  
