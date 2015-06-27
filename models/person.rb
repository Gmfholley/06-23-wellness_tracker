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
    @id = args["id"]
    @name = args[:name] || args["name"]
    @errors = []
    post_initialize
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
    if ExerciseEvent.where_match("person_id", id, "==").length > 0
        false
    else
        true
    end
  end

  # returns the total points from all this person's exercise events
  #
  # returns an Integer
  def total_points
    ExerciseEvent.points_for_person(id)
  end
  
  # returns the total points from all this person's exercise events between the start and end dates
  #
  # date_start - Date to start  (I believe SQL treats dates as a straight Integer)
  # date_end   - Date to end (again, SQL treats as an Integer)  
  #
  # returns an Integer
  def points(date_start, date_end)
    ExerciseEvent.points_for_person_within_dates(id, date_start, date_end)
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