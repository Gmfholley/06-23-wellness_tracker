class MenuItem
  attr_reader :key_user_returns, :user_message, :method
  
  def initialize(args)
    @key_user_returns = args[:key_user_returns].to_s
    @user_message = args[:user_message]
    @method = args[:method] #MethodToCall Object
  end
end
