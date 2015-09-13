class <%= classname %>Resource < ApplicationResource

  include Apiway::Resource

  depend_on <%= modelname %>


  access do
#   auth?
  end


  data do

#   <%= modelname %>.limit( params[ :limit ] ).map do |<%= varname %>|
#     {
#       id:   <%= varname %>.id,
#       name: <%= varname %>.name
#     }
#   end

  end


# def auth?
#   error :auth_error unless client[ :user_id ]
# end

end
