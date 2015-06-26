# require "../app.rb"
require 'date'

class ExerciseEvent
  include DatabaseConnector
  
  attr_accessor
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
  def initialize(args={})
    if args["id"].blank?
      @id = ""
    else
      @id = args["id"].to_i
    end

    date = args["date"] || args[:date]
    if date.is_a? Integer
      @date = date
    else
      @date = Date.strptime(date, '%m/%d/%y').to_time.to_i
    end

    person_id = (args[:person_id] || args["person_id"]).to_i
    @person_id = ForeignKey.new({id: person_id, class_name: Person})

    exercise_type_id = (args[:exercise_type_id] || args["exercise_type_id"]).to_i
    @exercise_type_id = ForeignKey.new({id: exercise_type_id, class_name: ExerciseType})

    duration_id = (args[:duration_id] || args["duration_id"]).to_i
    @duration_id = ForeignKey.new({id: duration_id, class_name: Duration})

    intensity_id = (args[:intensity_id] || args["intensity_id"]).to_i
    @intensity_id = ForeignKey.new({id: intensity_id, class_name: Intensity})

    points

    @errors = []
  end
  
  def person_id=(new_id)
    @person_id = ForeignKey.new({id: new_id, class_name: Person})
  end
  
  def exercise_type_id=(new_id)
    @exercise_type_id = ForeignKey.new({id: new_id, class_name: ExerciseType})
  end
  
  def duration_id=(new_id)
    @duration_id = ForeignKey.new({id: new_id, class_name: Duration})
  end
  
  def intensity_id=(new_id)
    @intensity_id = ForeignKey.new({id: new_id, class_name: Intensity})
  end
  
  def date=(new_date)
    @date = Date.strptime(new_date, '%m/%d/%y').to_time.to_i
  __END__
  
  
  def date_humanized
    Time.at(@date).to_date.strftime("%m/%d/%y")
  end
  
  def points
    @points = exercise_type.point_base * duration.num_quarter_hours * intensity.point_adjustment
  end
  
  # returns String representing this object's parameters
  #
  # returns String
  def to_s
    "person: #{person}\t\texercise type: #{exercise_type}\t\tdate: #{date}\t\tduration: #{duration}\t\tintensity: #{intensity}"
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
  
  # returns Boolean to indicate if this date-person-exercise type is a duplicate of a different id in the datbase
  #
  # returns Boolean or id of other id value
  def duplicate_date_person_type?
    binding.pry
    rec = CONNECTION.execute("SELECT * FROM #{table} WHERE person_id = #{person.id} AND date = #{@date} and exercise_type_id = #{exercise_type.id};")
    if rec.empty?
      false
    elsif rec.first["id"] == id
      false
    else
      rec.first["id"]
    end
  end
  
  # put your business rules here, and it returns Boolean to indicate if it is valid
  #
  # returns Boolean
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
    
    if !intensity_id.valid?
      @errors += intensity_id.errors
    end
    
    if duplicate_date_person_type?
      @errors << {message: "The database already has this person, date, and exercise type combination.  Change this event's date or find and increase the duration of the current record.", variabe: "date, exercise_type_id, person_id"}
    end
    
    # checks the number of points
    if points.to_s.empty?
      @errors << {message: "Length cannot be empty.", variable: "points"}
    elsif points.is_a? Integer
      if points < 0
        @errors << {message: "Points must be 0 or greater.", variable: "points"}
      end
    else
      @errors << {message: "Points must be a number.", variable: "points"}
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
  
    # returns whether @errors is empty
    @errors.empty?
  end
end