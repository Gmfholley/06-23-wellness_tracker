# require "../app.rb"



class Duration
  include DatabaseConnector
  
  # duration - length
  attr_reader :id, :errors
  attr_accessor :name, :num_quarter_hours
  
  
  # initializes a Duration id
  #
  # optional Hash argument
  #         name              - String of the rating
  #         id                - Integer of the id
  #         num_quarter_hours - Integer of the number of quarter hours
  #
  # returns an instance of the object
  def initialize(args={})
    if args["id"].blank?
      @id =  ""
    else
      @id = args["id"].to_i
    end
    @name = args[:name] || args["name"]
    @num_quarter_hours = (args[:num_quarter_hours] || args["num_quarter_hours"]).to_i
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
  #   if ExerciseEvent.where_match("duration_id", id, "==").length > 0
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
    if num_quarter_hours.to_s.empty?
      @errors << {message: "Number of quarter hours cannot be empty.", variable: "num_quarter_hours"}
    elsif num_quarter_hours.is_a? Integer
      if num_quarter_hours < 1
        @errors << {message: "Number of quarter hours must be greater than 0.", variable: "num_quarter_hours"}
      end
    else
      @errors << {message: "Number of quarter hours must be a number.", variable: "num_quarter_hours"}
    end
    
    @errors.empty?
  end
  
end

# This was just awesome code I wrote to put the values into Duration
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
#     l = Duration.new(name: s, num_quarter_hours: x)
#     l.save_record
#   when x >=4 && x < 8
#     l = Duration.new(name: "1 hour#{s}", num_quarter_hours: x)
#     l.save_record
#   when x >= 8
#     y = (x/4).to_i
#     l = Duration.new(name: "#{y} hours#{s}", num_quarter_hours: x )
#     l.save_record
#   end
# end
  
