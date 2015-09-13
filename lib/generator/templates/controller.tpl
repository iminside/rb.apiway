class <%= classname %>Controller < ApplicationController

  include Apiway::Controller


# before_action :auth?

# action :new do
#
#   begin
#     <%= modelname %>.create! params
#   rescue Exception => e
#     error e.message
#   end
#
# end

# def auth?
#   error :auth_error unless client[ :user_id ]
# end

end
