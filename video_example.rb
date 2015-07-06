class ExerciseType
  
  attr_reader :id, :errors
  attr_accessor :name, :points
  
  
  def initialize(args={})
    #... some stuff here
    
    
    @errors = []
    post_initialize
  end
  

  def valid?
    validate_field_type
    
    # more business logic here  

    @errors.length?
  end
  
  
  def save_record
    if valid?
      #...save to database
    else
      false
    end
  end
  
  
end


----------------------------------------------
    exercise_types database table

id            |   name            | points
--------------|-------------------|-----------
PRIMARY KEY   |                   |
INTEGER       |  TEXT             | INTEGER
NOT NULL      |  NOT NULL         | NOT NULL