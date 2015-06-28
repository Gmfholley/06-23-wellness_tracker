require "minitest/autorun"
require "../app.rb"


class ExerciseEventTest < Minitest::Test


  def test_initialize
    exercise_event = ExerciseEvent.new("id" => 1, "date" => "12/23/14", "person_id" => "1", "intensity_id" => "2", 
    "duration_id" => "3", "exercise_type_id" => "4")
    
    assert_equal("12/23/14", exercise_event.date_humanized)
    assert_equal(1, exercise_event.person.id)
    assert_equal(2, exercise_event.intensity.id)
    assert_equal(3, exercise_event.duration.id)
    assert_equal(4, exercise_event.exercise_type.id)
    
    exercise_event = ExerciseEvent.new(id: 1, date: "12/23/14", person_id: "1", intensity_id: "2", 
    duration_id: "3", exercise_type_id: "4")
    
    assert_equal("12/23/14", exercise_event.date_humanized)
    assert_equal(1, exercise_event.person.id)
    assert_equal(2, exercise_event.intensity.id)
    assert_equal(3, exercise_event.duration.id)
    assert_equal(4, exercise_event.exercise_type.id)
  end
  
  def test_changes_to_foreign_keys
    exercise_event = ExerciseEvent.new("id" => 1, "date" => "12/23/14", "person_id" => "1", "intensity_id" => "2", 
    "duration_id" => "3", "exercise_type_id" => "4")
    
    exercise_event.person_id = 5
    exercise_event.duration_id = 6
    exercise_event.intensity_id = 1
    exercise_event.exercise_type_id = 7
    exercise_event.date = "12/24/14"
    
    assert_equal(5, exercise_event.person_id.id)
    assert_equal(6, exercise_event.duration_id.id)
    assert_equal(1, exercise_event.intensity_id.id)
    assert_equal(7, exercise_event.exercise_type.id)
    assert_equal("12/24/14", exercise_event.date_humanized)
    
    exercise_event.person_id = "8"
    exercise_event.duration_id = "9"
    exercise_event.intensity_id = "3"
    exercise_event.exercise_type_id = "10"
    assert_equal(8, exercise_event.person_id.id)
    assert_equal(9, exercise_event.duration_id.id)
    assert_equal(3, exercise_event.intensity_id.id)
    assert_equal(10, exercise_event.exercise_type.id)
    assert_equal(Fixnum, exercise_event.points.class)
  end
  
  # def test_to_s
 #    exercise_event = ExerciseEvent.new("id" => 1, "name" => "Wendy", "description" => "In a world!", "rating_id" => 1,
 #    "studio_id" => 1, "length" => 1)
 #    exercise_event_s = "id:\t1\t\tname:\tWendy\t\trating:\tG\t\tstudio:\tParamount\t\tlength:\t1"
 #    # "id:\t#{@id}]\t\tname:\t#{name}\t\trating:\t#{rating}\t\tstudio:\t#{studio}\t\tlength:\t#{length}"
 #
 #    assert_equal(exercise_event_s, exercise_event.to_s)
 #  end
 #
 #
  def test_crud
    m = ExerciseEvent.new(id: 1, date: "12/24/14", person_id: "1", intensity_id: "2", 
    duration_id: "3", exercise_type_id: "4")
    assert_equal(Fixnum, m.save_record.class)
    m.duration_id = 4
    assert_equal(Fixnum, m.update_record.class)
    assert_equal(ExerciseEvent, ExerciseEvent.all.first.class)
    assert_equal(true, ExerciseEvent.ok_to_delete?(m.id))

    assert_equal(Array, ExerciseEvent.delete_record(m.id).class)

  end
  
  

  def test_duplicate_date_person_type
    m = ExerciseEvent.create_from_database(1)
    
    assert_equal(false, m.duplicate_date_person_type?)

    n= ExerciseEvent.new(date: m.date, person_id: m.person_id.id, intensity_id: m.intensity_id.id, 
    duration_id: m.duration_id.id, exercise_type_id: m.exercise_type_id.id)
    assert_equal(true, n.duplicate_date_person_type?)
    
    m.exercise_type_id = 2
    
    assert_equal(false, m.duplicate_date_person_type?)

  end

 
  def test_valid
    # Can't be nil
    m = ExerciseEvent.new(id: nil, date: nil, person_id: nil, intensity_id: nil, 
    duration_id: nil, exercise_type_id: nil)
    m.valid?
    assert_equal(6, m.errors.length)

    # can't be empty strings
    m = ExerciseEvent.new(id: "", date: "", person_id: "", intensity_id: "", 
    duration_id: "", exercise_type_id: "")
    m.valid?
    assert_equal(6, m.errors.length)

    # can't be whatever is created when no args are passed
    m = ExerciseEvent.new()
    m.valid?
    assert_equal(6, m.errors.length)


    # person, intensity, duration, type must belong to the table; length must be a number
    m = ExerciseEvent.new(id: 1, date: "12/24/14", person_id: 0, intensity_id: 0, 
    duration_id: 0, exercise_type_id: 0)
    m.valid?
    assert_equal(4, m.errors.length)

    # date must be greater than 0
    m = ExerciseEvent.new(id: 1, date: 0, person_id: "1", intensity_id: "2", 
    duration_id: "3", exercise_type_id: "4")
    m.valid?
    assert_equal(1, m.errors.length)


    # num_time_slots can't be more than the maximum number of time slots allowed
    m = ExerciseEvent.new(id: 1, date: "12/24/14")

    m.person_id = Person.all.last.id + 1
    m.intensity_id = Intensity.all.last.id + 1
    m.exercise_type_id = ExerciseType.all.last.id + 1
    m.duration_id = Duration.all.last.id + 1
    m.valid?
    assert_equal(4, m.errors.length)

  end
  #TODO - when create form is submitted in view, it bypasses the valid? method.  Why?
  
end