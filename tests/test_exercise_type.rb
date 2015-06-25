require "minitest/autorun"
require "../app.rb"

class ExerciseTypeTest < Minitest::Test

  
  def test_initialize
    duration = ExerciseType.new("id" => 1, "name" => "Purple", "point_base" => 4)
    assert_equal("Purple", duration.name)
    assert_equal(4, duration.point_base)
    duration2 = ExerciseType.new(name: "Purple", point_base: 4)
    assert_equal("Purple", duration2.name)
    assert_equal(4, duration2.point_base)
  end
  
  def test_crud
    p = ExerciseType.new(name: "test", point_base: 5)
    assert_equal(Fixnum, p.save_record.class)
    p.name = "Pur"
    assert_equal(Fixnum, p.update_record.class)
    assert_equal(ExerciseType, ExerciseType.all.first.class)
    assert_equal(true, ExerciseType.ok_to_delete?(p.id))
    assert_equal(Array, ExerciseType.delete_record(p.id).class)

  end
    
  # TODO - add this test back when I have ExerciseEvents working  
  # # tests true above in crud
  # def test_ok_to_delete
  #   assert_equal(false, ExerciseType.ok_to_delete?(3))
  # end
  #
  def test_valid
    # Can't be nil
    p = ExerciseType.new(name: nil, point_base: nil)
    p.valid?
    assert_equal(2, p.errors.length)
    
    # can't be empty strings
    p = ExerciseType.new(name: "", point_base: nil)    
    p.valid?
    assert_equal(2, p.errors.length)
    
    # can't be whatever is created when no args are passed
    p = ExerciseType.new()
    p.valid?
    assert_equal(2, p.errors.length)
    
    # num_quarter_hours can't be a string
    p = ExerciseType.new(name: "s", point_base: "s")    
    p.valid?
    assert_equal(1, p.errors.length)
    
    # num_quarter_hours can't be 0
    p = ExerciseType.new(name: "s", point_base: 0)    
    p.valid?
    assert_equal(1, p.errors.length)
    
    # should work here
    p = ExerciseType.new(name: "s", point_base: 1)    
    p.valid?
    assert_equal(0, p.errors.length)
    
  end
  
end