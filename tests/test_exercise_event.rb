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
    assert_equal(Fixnum, n.duplicate_date_person_type?.class)
    
    
    m.exercise_type_id = 2
    
    assert_equal(false, m.duplicate_date_person_type?)

  end

 #
 #  def test_valid
 #    # Can't be nil
 #    m = ExerciseEvent.new(name: nil, description: nil, studio_id: nil, rating_id: nil, length: nil)
 #    m.valid?
 #    assert_equal(5, m.errors.length)
 #
 #    # can't be empty strings
 #    m = ExerciseEvent.new(name: "", description: "", studio_id: "", rating_id: "", length: "")
 #    m.valid?
 #    assert_equal(5, m.errors.length)
 #
 #    # can't be whatever is created when no args are passed
 #    m = ExerciseEvent.new()
 #    m.valid?
 #    assert_equal(5, m.errors.length)
 #
 #
 #    # rating & studio id must belong to the table; length must be a number
 #    m = ExerciseEvent.new(name: "s", description: "s", studio_id: "s", rating_id: "s", length: "s")
 #    m.valid?
 #    assert_equal(3, m.errors.length)
 #
 #    # length must be 0 or greater, and studio & rating must belong to the table
 #    m = ExerciseEvent.new(name: 0, description: 0, studio_id: 0, rating_id: 0, length: 0)
 #    m.valid?
 #    assert_equal(3, m.errors.length)
 #
 #
 #    # num_time_slots can't be more than the maximum number of time slots allowed
 #    m = ExerciseEvent.new(name: 1, description: 1, studio_id: Studio.all.last.id + 1, rating_id: Rating.all.last.id + 1, length: 0)
 #    m.valid?
 #    assert_equal(3, m.errors.length)
 #    m.studio_id = Studio.all.last.id
 #    m.rating_id = Rating.all.last.id
 #    m.valid?
 #    assert_equal(0, m.errors.length)
 #
 #  end

  
end