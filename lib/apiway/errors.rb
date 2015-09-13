module Apiway


  class EventHandlerNotExists < StandardError

    def initialize( name )
      super "Event handler \"#{ name }\" not exists"
    end

  end


  class ControllerNotExists < StandardError

    def initialize( name )
      super "\"#{ name }\" not exists"
    end

  end


  class ControllerActionNotExists < StandardError

    def initialize( controller_name, action_name )
      super "Action \"#{ action_name }\" not exists in \"#{ controller_name }\""
    end

  end


  class ResourceNotExists < StandardError

    def initialize( name )
      super "\"#{ name }\" not exists"
    end

  end


  class ResourceError < StandardError

    attr_reader :params

    def initialize( params = nil )
      @params = params
    end

  end


  class ControllerError < StandardError

    attr_reader :params

    def initialize( params = nil )
      @params = params
    end

  end


end
