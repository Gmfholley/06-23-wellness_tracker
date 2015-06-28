# require "../app.rb"
require 'date'

class ExerciseEvent
  include DatabaseConnector
  
  attr_reader :id, :errors, :exercise_type_id, :person_id, :duration_id, :intensity_id, :date
  attr_reader :person_name, :duration_name, :intensity_name, :exercise_type_name
  
  # initializes object
  #
  # args -      Options Hash
  #             id                  - Integer of the ID number of record in the database
  #             person_id           - Integer of the person's id
  #             exercise_type_id    - Integer of the exercise_type_id
  #             duration_id         - Integer of the rating_id in ratings table
  #             inentsity_id        - Integer of the studio_id in studios table
  #             points              - Integer of the length of the movie
  #             date                - Date or string in MM-DD-YY form
  #
  # returns self
  def initialize(args={})
    if args["id"].blank?
      @id = ""
    else
      @id = args["id"].to_i
    end
    set_date(args["date"] || args[:date])
    @person_id = set_foreign_key((args[:person_id] || args["person_id"]), Person)
    @exercise_type_id = set_foreign_key((args[:exercise_type_id] || args["exercise_type_id"]), ExerciseType)
    @duration_id = set_foreign_key((args[:duration_id] || args["duration_id"]), Duration)
    @intensity_id = set_foreign_key((args[:intensity_id] || args["intensity_id"]), Intensity)
    
    # store these variables in Ruby if available so you don't have to make multiple trips to database
    # only useful if you are using joins to get this info in one SQL statement
    @person_name = args["person_name"]
    @exercise_type_name = args["exercise_type_name"]
    @duration_name = args["duration_name"]
    @intensity_name = args["intensity_name"]
    @errors = []
    post_initialize
  end
  
  
  # sets the person's id
  #
  # new_id - Integer
  #
  # returns the Foreign Key
  def person_id=(new_id)
    if allow_editing?
      @person_id = set_foreign_key(new_id, Person)
      @person_name = person.name
    end
  end
  
  # sets the exercise_type id
  #
  # new_id - Integer
  #
  # returns the Foreign Key
  def exercise_type_id=(new_id)
    if allow_editing?
      @exercise_type_id = set_foreign_key(new_id, ExerciseType)
      @exercise_type_name = exercise_type.name
    end
  end
  
  # sets the duration id
  #
  # new_id - Integer
  #
  # returns the Foreign Key
  def duration_id=(new_id)
    if allow_editing?
      @duration_id = set_foreign_key(new_id, Duration)
      @duration_name = duration.name
    end
  end
  
  # sets the intensity id
  #
  # new_id - Integer
  #
  # returns the Foreign Key
  def intensity_id=(new_id)
    if allow_editing?
      @intensity_id = set_foreign_key(new_id, Intensity)
      @intensity_name = intensity.name
    end
  end
  
  # sets the date
  #
  # new_date - String of the date
  #
  # returns the integer of the date
  def date=(new_date)
    if allow_editing?
      set_date(new_date)
    end
  end
  
  # returns the date as a String in mm/dd/yy form
  #
  # returns String
  def date_humanized
    begin
      Time.at(@date).to_date.strftime("%m/%d/%y")
    rescue
      nil
    end
  end
  
  # calculates and sets the points
  #
  # returns an Integer (defaults to 0)
  def points
    begin
      @points = exercise_type.point_base * duration.num_quarter_hours * intensity.point_adjustment
    rescue
      0
    end
  end
  
  # Array of the field names for this object from the database
  # NOTE:
  # An over write of the database_connector method, which assumes all parameters are field names
  # This object stores extra variables so as to make fewer trips to the database
  #     but these extra variables are not stored in the database.
  #
  # returns Array of strings
  def database_field_names
    ["person_id", "exercise_type_id", "intensity_id", "duration_id", "date"]
  end
  
  # Array of methods/parameters that should be displayed
  #
  # returns an Array of strings
  def display_fields
    ["person_name", "date_humanized", "exercise_type_name", "intensity_name", "duration_name", "points"]
  end
  
  # returns String representing this object's parameters
  #
  # returns String
  def to_s
    "person: #{person_name}\t\texercise type: #{exercise_type_name}\t\tdate: #{date_humanized}\t\tduration: #{duration_name}\t\tintensity: #{intensity_name}\t\tpoints: #{points}"
  end
  
  # returns the person's name
  #
  # returns ForeignKey
  def person
    person_id.get_object
  end
  
  # returns the exercise type name
  #
  # returns ForeignKey
  def exercise_type
    exercise_type_id.get_object
  end
  
  # returns the intensity name
  #
  # returns ForeignKey
  def intensity
    intensity_id.get_object
  end
  
  # returns the duration name
  #
  # returns ForeignKey
  def duration
    duration_id.get_object
  end
  
  # returns an ExerciseObject that matches this date, person, and type
  #
  # returns an ExerciseObject
  def this_date_person_and_type
    rec = CONNECTION.execute("SELECT * FROM #{table} WHERE person_id = #{person.id} AND date = #{date} and exercise_type_id = #{exercise_type.id};").first
    if rec.blank?
      ExerciseEvent.new
    else
      ExerciseEvent.new(rec)
    end
  end
  
  # returns Boolean to indicate if this date-person-exercise type is a duplicate of a different id in the datbase
  #
  # returns Boolean
  def duplicate_date_person_type?
    self.id != this_date_person_and_type.id && this_date_person_and_type.id != ""
  end
  
  # put your business rules here, and it returns Boolean to indicate if it is valid
  #
  # returns Boolean
  def valid?
    @errors = []
    points   #calculates points, so it must be at least 0
    
    validate_field_types  #checks blank and primitive data types

   if integer?("date")
      if convert_int_to_date(date) < smallest_valid_date
        @errors << 
          {message: "The event cannot be edited when it is older than #{smallest_valid_date.to_s}.  No changes to 
          this page will be saved.", variable: "date"}
      elsif convert_int_to_date(date) > largest_valid_date
        @errors << {message: "The event cannot made for a date before #{largest_valid_date.to_s}.", variable: "date"}
      end
        
    end
    
    # only do a database query if you have good enough data to check the database
    if @errors.length == 0
      if duplicate_date_person_type?
        @errors << 
          {message: 
          "The database already has this person, date, and exercise type combination. It is record 
          #{this_date_person_and_type.id}. Change this event's date or exercise type or increase the duration of that 
          record.", 
          variabe: "date, exercise_type_id, person_id"}
      end
    end

    if points < 0
      @errors << {message: "Points must be 0 or greater.", variable: "points"}
    end
      
    # returns whether @errors is empty
    @errors.empty?
  end
  
############################
  #  returns a person's total points from all their exercise events
  #
  # id - Integer of the person_id
  #
  # returns an Integer (0 if nil)
  def self.points_for_person(id)
    ExerciseEvent.sum_field_where("points", "person_id", id, "==").to_i
  end
  
  
  # TODO - refactor to handle some of this Date stuff
  # gets the points for this person within the dates
  #
  #     id            - Integer of person_id
  #     date_start    - String of the date in "mm/dd/yy"
  #     date_end      - String of the date in "mm/dd/yy"
  #
  # Returns an Integer (0 if nil)
  def self.points_for_person_within_dates(id, date_start, date_end)
    date_start_int = set_any_date(date_start)
    date_end_int = set_any_date(date_end)
    
    if !id.blank?
      query_string = "SELECT SUM(points) FROM #{self.to_s.underscore.pluralize} WHERE person_id = #{id} AND 
    date >= #{date_start_int} AND date <= #{date_end_int};"
      #This returns an Array of a hash with SUM(exercise_events.points)
      CONNECTION.execute(query_string).first[0].to_i
    else
      0
    end
  end
  
  # over-writes the all database_connector method for efficiency because this object has four foreign keys
  # returns all ExerciseEvents
  #
  # returns Array of Objects
  def self.all
    query_string = 
    "SELECT exercise_events.id, exercise_events.date, exercise_events.person_id,    
            exercise_events.intensity_id, exercise_events.duration_id, exercise_events.exercise_type_id, 
            exercise_events.points, durations.name AS duration_name, people.name AS person_name,
            exercise_types.name AS exercise_type_name, intensities.name AS intensity_name
    FROM exercise_events
    JOIN people ON people.id == exercise_events.person_id
    JOIN exercise_types ON exercise_types.id == exercise_events.exercise_type_id
    JOIN intensities ON intensities.id == exercise_events.intensity_id
    JOIN durations ON durations.id == exercise_events.duration_id
    ORDER BY people.name ASC, exercise_events.date ASC;"
    
    results = run_sql(query_string)
    self.as_objects(results)
  end
  
  # over-writes the all database_connector method for efficiency because this object has four foreign keys
  # returns this ExerciseEvent
  #
  # id - Integer of the id
  #
  # returns ExerciseEvent
  def self.create_from_database(id)
    query_string = 
    "SELECT exercise_events.id, exercise_events.date, exercise_events.person_id,    
            exercise_events.intensity_id, exercise_events.duration_id, exercise_events.exercise_type_id, 
            exercise_events.points, durations.name AS duration_name, people.name AS person_name,
            exercise_types.name AS exercise_type_name, intensities.name AS intensity_name
    FROM exercise_events
    JOIN people ON people.id == exercise_events.person_id
    JOIN exercise_types ON exercise_types.id == exercise_events.exercise_type_id
    JOIN intensities ON intensities.id == exercise_events.intensity_id
    JOIN durations ON durations.id == exercise_events.duration_id
    WHERE exercise_events.id = #{id};"
    
    rec = run_sql(query_string).first
    if rec.nil?
      self.new
    else
      self.new(rec)
    end
  end
  
  private
  
  
  # returns a Boolean if you can edit this event
  #
  # returns Boolean
  def allow_editing?
    convert_int_to_date(date) > smallest_valid_date && !date.blank?
  end
  
  # smallest DateTime object that is valid
  #
  # returns DateTime
  def smallest_valid_date
    today - 7
  end
  
  
  # largest DateTime object that is valid
  #
  # returns DateTime
  def largest_valid_date
    today
  end
  
  # date - checks if integer, blank or a String in mm/dd/yy form
  #
  # returns @date
  def set_date(date)  
    @date = set_any_date(date)
    post_initialize
  end
  
  # returns the date after it has been rendered into an Integer or nil if not correct
  # Note: Chronic returns a Time object and it is affected by time
  #     I only want date data, so I set all dates to noon (if set to midnight, our system has timezone difficulties)
  #
  # date - String or Integer of the date
  #
  # returns Integer or nil
  def set_any_date(date)
    begin
      if date.is_a? Integer or date.blank?
        return date
      else
        return Chronic.parse("#{date} noon").to_i
      end
    rescue
      return nil
    end
  end
  
  # converts Time as an Integer to DateTime object
  #
  # returns a DateTime object
  def convert_int_to_date(int_date)
    Time.at(int_date).to_datetime
  end
  
  # returns a DateTime object of today at noon
  def today
    Chronic.parse("today noon").to_datetime
  end
  
  # returns the ForeignKey object for this id and class
  #
  # this_id     - Integer of the id
  # name_class  - Class
  #
  # returns a ForiegnKey
  def set_foreign_key(this_id, name_class)
    ForeignKey.new(id: this_id, class_name: name_class)
  end
  
end