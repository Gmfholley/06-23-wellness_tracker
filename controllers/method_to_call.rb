class MethodToCall
  
  attr_reader :method_name, :parameters
  
  def initialize(args={})
    @method_name = args["method_name"] || args[:method_name]
    @parameters = args["parameters"] || args[:parameters] || []
  end
  
end