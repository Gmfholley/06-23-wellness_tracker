
class Person
  
  include DatabaseConnector
  
  # Person
  attr_reader :id, :errors
  attr_accessor :name
  
  
  # initializes a Person id
  #
  # optional Hash argument
  #         rating  - String of the rating
  #         id      - Integer of the id
  #
  # returns an instance of the object
  def initialize(args={})
    if args["id"].blank?
      @id =  ""
    else
      @id = args["id"].to_i
    end
    @name = args[:name] || args["name"]
    @errors = []
  end
  
  def to_s
    "id: #{id}\t\tname: #{name}"
  end
  
  # TODO - add this method back to Person when I have my ExerciseEvent class up and running
  # # returns Boolean if ok to delete
  # #
  # # id - Integer of the id to delete
  # #
  # # returns Boolean
  # def self.ok_to_delete?(id)
  #   if ExerciseEvent.where_match("person_id", id, "==").length > 0
  #       false
  #   else
  #       true
  #   end
  # end
  

  # returns the total points from all this person's exercise events
  #
  # returns an Integer
  def points
    sum = 0
    query_string = "SELECT SUM(exercise_events.points) FROM exercise_events WHERE exercise_events.person_id = #{@id};"
    #TODO - what does this return?  Borrowed this code from timeslot, but it had a join
    staff_array = CONNECTION.execute(query_string)
    staff_array.each do |hash|
      sum += hash["SUM(locations.num_staff)"]
    end
    sum
  end
  
  # returns the total points from all this person's exercise events between the start and end dates
  #
  # date_start - Date to start  (I believe SQL treats dates as a straight Integer)
  # date_end   - Date to end (again, SQL treats as an Integer)  
  #
  # returns an Integer
  def points(date_start, date_end)
    sum = 0
    query_string = "SELECT SUM(exercise_events.points) FROM exercise_events WHERE exercise_events.person_id = #{@id} AND 
    exercise_events.date >= date_start AND exercise_events.date <= date_end;"
    #TODO - what does this return?  Borrowed this code from timeslot, but it had a join
    staff_array = CONNECTION.execute(query_string)
    staff_array.each do |hash|
      sum += hash["SUM(locations.num_staff)"]
    end
    sum
  end
  
  # returns Array of all the location-times for this movie
  #
  # returns Array
  def exercise_events
    ExerciseEvent.where_match("person_id", id, "==")
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
    @errors.empty?
  end
  
end