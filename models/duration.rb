# require "../app.rb"



class Duration
  include DatabaseConnector
  
  # duration - length
  attr_reader :id, :errors, :num_quarter_hours
  attr_accessor :name
  
  # initializes a Duration id
  #
  # optional Hash argument
  #         name              - String of the duration
  #         id                - Integer of the id
  #         num_quarter_hours - Integer of the number of quarter hours
  #
  # returns an instance of the object
  def initialize(args={})
    @id = args["id"]
    @name = args[:name] || args["name"]
    @num_quarter_hours = args[:num_quarter_hours] || args["num_quarter_hours"]
    @errors = []
    post_initialize
  end
  
  # setter method for num_quarter_hours that runs post_initialize method to set the correct ints
  #
  # returns num_quarter_hours
  def num_quarter_hours=(new_quarter_hours)
    @num_quarter_hours = new_quarter_hours
    post_initialize
    @num_quarter_hours
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
    if ExerciseEvent.where_match("duration_id", id, "==").length > 0
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
    
    # checks each field type and adds error messages if it does not meet requirements from the table
    validate_field_types
    
    
    if integer?("num_quarter_hours")
      if num_quarter_hours < 1
        @errors << {message: "Number of quarter hours must be greater than 0.", variable: "num_quarter_hours"}
      end
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
  
