require "minitest/autorun"
require "../app.rb"

class DurationTest < Minitest::Test
  # One of my specs is that the tip_amount method should blah blah blah.
  
  def test_initialize
    duration = Duration.new("id" => 1, "name" => "Purple", "num_quarter_hours" => 4)
    assert_equal("Purple", duration.name)
    assert_equal(4, duration.num_quarter_hours)
    duration2 = Duration.new(name: "Purple", num_quarter_hours: 4)
    assert_equal("Purple", duration2.name)
    assert_equal(4, duration2.num_quarter_hours)
  end
  
  def test_crud
    p = Duration.new(name: "test", num_quarter_hours: 5)
    assert_equal(Fixnum, p.save_record.class)
    p.name = "Pur"
    assert_equal(Fixnum, p.update_record.class)
    assert_equal(Duration, Duration.all.first.class)
    assert_equal(true, Duration.ok_to_delete?(p.id))
    assert_equal(Array, Duration.delete_record(p.id).class)

  end
    
  # TODO - add this test back when I have ExerciseEvents working  
  # # tests true above in crud
  # def test_ok_to_delete
  #   assert_equal(false, Duration.ok_to_delete?(3))
  # end
  #
  def test_valid
    # Can't be nil
    p = Duration.new(name: nil, num_quarter_hours: nil)
    p.valid?
    assert_equal(2, p.errors.length)
    
    # can't be empty strings
    p = Duration.new(name: "", num_quarter_hours: nil)    
    p.valid?
    assert_equal(2, p.errors.length)
    
    # can't be whatever is created when no args are passed
    p = Duration.new()
    p.valid?
    assert_equal(2, p.errors.length)
    
    # num_quarter_hours can't be a string
    p = Duration.new(name: "s", num_quarter_hours: "s")    
    p.valid?
    assert_equal(1, p.errors.length)
    
    # num_quarter_hours can't be 0
    p = Duration.new(name: "s", num_quarter_hours: 0)    
    p.valid?
    assert_equal(1, p.errors.length)
    
    # should work here
    p = Duration.new(name: "s", num_quarter_hours: 1)    
    p.valid?
    assert_equal(0, p.errors.length)
    
  end
  
end