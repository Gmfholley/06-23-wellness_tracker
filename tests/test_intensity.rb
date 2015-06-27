require "minitest/autorun"
require "../app.rb"

class IntensityTest < Minitest::Test
  # One of my specs is that the tip_amount method should blah blah blah.
  
  def test_initialize
    duration = Intensity.new("id" => 1, "name" => "Purple", "point_adjustment" => 4)
    assert_equal("Purple", duration.name)
    assert_equal(4, duration.point_adjustment)
    duration2 = Intensity.new(name: "Purple", point_adjustment: 4)
    assert_equal("Purple", duration2.name)
    assert_equal(4, duration2.point_adjustment)
  end
  
  def test_crud
    p = Intensity.new(name: "test", point_adjustment: 5)
    assert_equal(Fixnum, p.save_record.class)
    p.name = "Pur"
    assert_equal(Fixnum, p.update_record.class)
    assert_equal(Intensity, Intensity.all.first.class)
    assert_equal(true, Intensity.ok_to_delete?(p.id))
    assert_equal(Array, Intensity.delete_record(p.id).class)

  end
    

  # tests true above in crud
  def test_ok_to_delete
    assert_equal(false, Intensity.ok_to_delete?(2))
    assert_equal(false, Intensity.ok_to_delete?(1))
    #at this time, I have no intensity of type 3, but there are only 3 intensity ids in my current program
    # assert_equal(true, Intensity.ok_to_delete?(3))
    assert_equal(true, Intensity.ok_to_delete?(0))
  end
  
  def test_valid
    # Can't be nil
    p = Intensity.new(name: nil, point_adjustment: nil)
    p.valid?
    assert_equal(3, p.errors.length)
    
    # can't be empty strings
    p = Intensity.new(name: "", point_adjustment: nil)    
    p.valid?
    assert_equal(3, p.errors.length)
    
    # can't be whatever is created when no args are passed
    p = Intensity.new()
    p.valid?
    assert_equal(3, p.errors.length)
    
    # point_adjustment can't be a string
    p = Intensity.new(name: "s", point_adjustment: "s")    
    p.valid?
    assert_equal(1, p.errors.length)
    
    # point_adjustment can't be 0
    p = Intensity.new(name: "s", point_adjustment: 0)    
    p.valid?
    assert_equal(1, p.errors.length)
    
    # point_adjustment shoudl work
    p = Intensity.new(name: "s", point_adjustment: 1)    
    p.valid?
    assert_equal(0, p.errors.length)
    
  end
  
end