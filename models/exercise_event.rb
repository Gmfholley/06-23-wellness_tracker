# require "../app.rb"
require 'date'

class ExerciseEvent
  include DatabaseConnector
  
  
  # TODO - Because of the foreign keys and dates, do not run post_initialize on this method
  # but consider doing it sometime in future
  
  attr_reader :id, :errors, :exercise_type_id, :person_id, :duration_id, :intensity_id, :date
  
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
    
    @person_id = set_foreign_key((args[:person_id] || args["person_id"]).to_i, Person)
    @exercise_type_id = set_foreign_key((args[:exercise_type_id] || args["exercise_type_id"]).to_i, ExerciseType)
    @duration_id = set_foreign_key((args[:duration_id] || args["duration_id"]).to_i, Duration)
    @intensity_id = set_foreign_key((args[:intensity_id] || args["intensity_id"]).to_i, Intensity)
    @errors = []
  end
  
  
  # sets the person's id
  #
  # new_id - Integer
  #
  # returns the Foreign Key
  def person_id=(new_id)
    @person_id = set_foreign_key(new_id.to_i, Person)
  end
  
  # sets the exercise_type id
  #
  # new_id - Integer
  #
  # returns the Foreign Key
  def exercise_type_id=(new_id)
    @exercise_type_id = set_foreign_key(new_id.to_i, ExerciseType)
  end
  
  # sets the duration id
  #
  # new_id - Integer
  #
  # returns the Foreign Key
  def duration_id=(new_id)
    @duration_id = set_foreign_key(new_id.to_i, Duration)
  end
  
  # sets the intensity id
  #
  # new_id - Integer
  #
  # returns the Foreign Key
  def intensity_id=(new_id)
    @intensity_id = set_foreign_key(new_id.to_i, Intensity)
  end
  
  # sets the date
  #
  # new_date - String of the date
  #
  # returns the integer of the date
  def date=(new_date)
    set_date(new_date)
  end
  
  # returns the date as a String in mm/dd/yy form
  #
  # returns String
  def date_humanized
    Time.at(@date).to_date.strftime("%m/%d/%y")
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
  
  # returns String representing this object's parameters
  #
  # returns String
  def to_s
    "person: #{person}\t\texercise type: #{exercise_type}\t\tdate: #{date_humanized}\t\tduration: #{duration}\t\tintensity: #{intensity}"
  end
  
  # returns the person's name
  #
  # returns String
  def person
    person_id.get_object
  end
  
  # returns the exercise type name
  #
  # returns String
  def exercise_type
    exercise_type_id.get_object
  end
  
  # returns the intensity name
  #
  # returns String
  def intensity
    intensity_id.get_object
  end
  
  # returns the duration name
  #
  # returns String
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
  # TODO - did not use the valid_field_type DRY code that I could have here
  #         because ForeignKeys got in my way a little
  #         Would be good to somehow incorporate database_connector modules somehow here
  def valid?
    @errors = []
    # check thename exists and is not empty
    if !person_id.valid?
      @errors += person_id.errors
    end
    
    if !duration_id.valid?
      @errors += duration_id.errors
    end
    
    if !exercise_type_id.valid?
      @errors += exercise_type_id.errors
    end
    
    # checks the number of points
    if @date.to_s.empty?
      @errors << {message: "Date cannot be empty.", variable: "date"}
    elsif @date.is_a? Integer
      if @date < 1
        @errors << {message: "Date must be greater than 0.", variable: "date"}
      end
    else
      @errors << {message: "Date must be a number.", variable: "date"}
    end
    
    # only do a database query if you have good enough data to check the database
    if @errors.length == 0
      if duplicate_date_person_type?
        @errors << {message: "The database already has this person, date, and exercise type combination.  Change this event's date or find and increase the duration of the current record.", variabe: "date, exercise_type_id, person_id"}
      end
    end
    
    if !intensity_id.valid?
      @errors += intensity_id.errors
    end
    
    # checks the number of points
    points
    if points.to_s.empty?
      @errors << {message: "Length cannot be empty.", variable: "points"}
    elsif points.is_a? Integer
      if points < 0
        @errors << {message: "Points must be 0 or greater.", variable: "points"}
      end
    else
      @errors << {message: "Points must be a number.", variable: "points"}
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
  
  
  # TODO - refactor into date class to handle some of this
  # gets the points for this person within the dates
  #
  #     id            - Integer of person_id
  #     date_start    - String of the date in "mm/dd/yy"
  #     date_end      - String of the date in "mm/dd/yy"
  #
  # Returns an Integer (0 if nil)
  def self.points_for_person_within_dates(id, date_start, date_end)
    # ExerciseEvent.sum_field_where("points", "person_id", id, "==")
  #   # convert to int first
    date_start_int = Date.strptime(date_start, "%m/%d/%y").to_time.to_i
    date_end_int = Date.strptime(date_end, "%m/%d/%y").to_time.to_i
    
    if !id.blank?
      query_string = "SELECT SUM(points) FROM #{self.to_s.underscore.pluralize} WHERE person_id = #{id} AND 
    date >= #{date_start_int} AND date <= #{date_end_int};"
      #This returns an Array of a hash with SUM(exercise_events.points)
      CONNECTION.execute(query_string).first[0].to_i
    else
      0
    end
  end
  
  private
  
  # smallest date that is valid
  def smallest_valid_date
    
  end
  
  
  # largest date that is valid
  def largest_valid_date
    
  end
  
  #TODO - if they enter this as mm/dd/yyyy, it puts it as mm/dd/yy and leaves off last two digits of year
  # sets date from initialization method
  #
  # date - checks if integer, blank or a String in mm/dd/yy form
  #
  # returns @date
  def set_date(date)  
    begin
      if date.is_a? Integer
        @date = date
      else
        @date = Date.strptime(date, '%m/%d/%y').to_time.to_i
      end
    rescue
      @date = nil
    end
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