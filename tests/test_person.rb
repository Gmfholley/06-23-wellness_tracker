require "minitest/autorun"
require "../app.rb"

class PersonTest < Minitest::Test
  # One of my specs is that the tip_amount method should blah blah blah.
  
  def test_initialize
    person = Person.new("id" => 1, "name" => "Purple")
    assert_equal("Purple", person.name)
    
    person2 = Person.new(name: "Purple")
    assert_equal("Purple", person2.name)
    
  end
  
  def test_crud
    p = Person.new(name: "test")
    assert_equal(Fixnum, p.save_record.class)
    p.name = "Pur"
    assert_equal(Fixnum, p.update_record.class)
    assert_equal(true, Person.ok_to_delete?(p.id))
    assert_equal(Array, Person.delete_record(p.id).class)
    assert_equal(Person, Person.all.first.class)
  end
    

  # tests true above in crud
  def test_ok_to_delete
    assert_equal(false, Person.ok_to_delete?(1))
    assert_equal(true, Person.ok_to_delete?(0))
    assert_equal(true, Person.ok_to_delete?(Person.all.last.id + 10))    
  end
  
  
  def test_points
    p = Person.create_from_database(1)
    assert_equal(Fixnum, p.total_points.class)
    assert_equal(Fixnum, p.points("01/01/00", "12/23/15").class)
   
    p = Person.new
    assert_equal(0, p.total_points)
    assert_equal(0, p.points("01/01/00", "12/23/15"))
    
    
  end
  
  def test_valid
    # Can't be nil
    p = Person.new(name: nil)
    p.valid?
    assert_equal(1, p.errors.length)
    
    # can't be empty strings
    p = Person.new(name: "")    
    p.valid?
    assert_equal(1, p.errors.length)
    
    # can't be whatever is created when no args are passed
    p = Person.new()
    p.valid?
    assert_equal(1, p.errors.length)
  end
  
end