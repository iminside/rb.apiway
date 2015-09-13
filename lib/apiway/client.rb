module Apiway

  class Client


    HANDLERS = Hash[
      API::ALIVE,        :alive,
      API::QUERY,        :run_controller,
      RESOURCE::SYNC,    :sync_resource,
      RESOURCE::DESTROY, :destroy_resource
    ]


    class << self

      def all
        @@all ||= []
        @@all.each { |client| yield client } if block_given?
        @@all
      end

      def sync_changes( changed_models )
        all { |client| client.sync_changes changed_models }
      end

      def on_connected( &block )
        block_given? ? @@on_connected    = block : @@on_connected    ||= Proc.new {}
      end

      def on_message( &block )
        block_given? ? @@on_message      = block : @@on_message      ||= Proc.new {}
      end

      def on_disconnected( &block )
        block_given? ? @@on_disconnected = block : @@on_disconnected ||= Proc.new {}
      end

    end


    def initialize( ws )
      @ws = ws
      @ws.onopen    {       on_connected    }
      @ws.onmessage { |msg| on_message msg  }
      @ws.onclose   {       on_disconnected }
      @storage    = {}
      @resources  = {}
    end

    def []( name = nil )
      @storage[ name ]
    end

    def []=( name, value )
      @storage[ name ] = value
      Thread.current[ :changed_models ].concat Apiway::Model.all
      value
    end

    def sync_changes( changed_models )
      @resources.values.each { |resource| resource.sync_changes changed_models }
    end

    def trigger( *args )
      send_event API::TRIGGER, args: args
    end


    private

    def processing
      begin
        Thread.new {
          Thread.current[ :changed_models ]  = []
          Thread.current[ :methods_to_call ] = []
          yield
          self.class.sync_changes Thread.current[ :changed_models ].uniq
          call_methods Thread.current[ :methods_to_call ]
        }.join
      rescue Exception => e
        Log.error "#{ e.message }\n#{ e.backtrace.join "\n" }"
      end
    end

    def on_connected
      processing do
        self.class.all << self
        instance_eval &self.class.on_connected
      end
      Log.info "Client connected"
    end

    def on_message( msg )
      @msg = parseMessage( msg ) rescue { event: API::ALIVE, data: nil }
      Log.debug "New message: \n#{ JSON.pretty_generate( @msg ) }" if Log.debug?
      processing do
        instance_exec @msg, &self.class.on_message
        handler = HANDLERS[ @msg[ :event ] ] or raise EventHandlerNotExists, @msg[ :event ]
        send handler, @msg[ :data ]
      end
    end

    def on_disconnected
      processing do
        self.class.all.delete self
        instance_eval &self.class.on_disconnected
      end
      Log.info "Client disconnected"
    end

    def parseMessage( msg )
      msg = JSON.parse msg, quirks_mode: true
      msg.keys_to_sym!
    end

    def send_json( msg )
      @ws.send JSON.generate( msg, quirks_mode: true )
      Log.debug "Send message: \n#{ JSON.pretty_generate( msg ) }" if Log.debug?
    end

    def send_event( event, data = nil )
      send_json event: event, data: data
    end

    def success( result )
      send_event API::SUCCESS, result: result, query_id: @msg[ :data ][ :query_id ]
    end

    def failure( result )
      send_event API::FAILURE, result: result, query_id: @msg[ :data ][ :query_id ]
    end

    def call_methods( methods )
      methods.each { |method, args| send method, *args }
    end

    def alive( data )
      send_event API::ALIVE
    end

    def run_controller( data )
      name, action, params = data.values_at :name, :action, :params
      name = "#{ name }Controller"
      begin
        controller = Object.const_get( name ).new action.to_sym, self, params
      rescue NameError
        raise ControllerNotExists, name
      else
        controller.run
      end
    end

    def sync_resource( data )
      id, name, params = data.values_at :id, :name, :params
      name = "#{ name }Resource"
      begin
        @resources[ id ] ||= Object.const_get( name ).new id, self
      rescue
        raise ResourceNotExists, name
      else
        @resources[ id ].set_params( params ).sync
      end
    end

    def destroy_resource( data )
      @resources.delete data[ :id ]
    end

  end

end
