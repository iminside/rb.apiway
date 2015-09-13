module Apiway

  module Controller



    class << self

      def included( base )
        base.class_eval do
          extend  ClassMethods
          include InstanceMethods
        end
      end

    end



    module ClassMethods

      def action( name, &block )
        block_given? ? actions[ name ] = block : actions[ name ] or raise ControllerActionNotExists.new( self.name, name )
      end

      def before_action( method_name, only: [], except: [] )
        register_filter :before, method_name, only, except
      end

      def after_action( method_name, only: [], except: [] )
        register_filter :after, method_name, only, except
      end

      def select_filters( type, action_name )
        filters( type ).select do |method_name, only, except|
          ( only.empty? || only.include?( action_name ) ) && ( except.empty? || !except.include?( action_name ) )
        end
      end


      private

      def actions
        @actions ||= {}
      end

      def filters( type )
        ( @filters ||= {} )[ type ] ||= []
      end

      def register_filter( type, method_name, only, except )
        only   = [].push( only ).flatten
        except = [].push( except ).flatten
        filters( type ) << [ method_name, only, except ]
      end

    end



    module InstanceMethods

      def initialize( action_name, client, params = {} )
        @action_name = action_name
        @action      = self.class.action @action_name
        @client      = client
        @params      = params
      end

      def run
        begin
          run_filters :before
          result = run_action
          run_filters :after
        rescue ControllerError => e
          failure e.params
        else
          success result
        end
      end


      protected

      attr_reader :client, :params

      def trigger( *args )
        add_method_to_call :trigger, args
      end

      def error( params )
        raise ControllerError, params
      end


      private

      def run_action
        instance_eval &@action
      end

      def run_filters( type )
        self.class.select_filters( type, @action_name ).each { |method_name, only, except| send method_name }
      end

      def add_method_to_call( method, args )
        Thread.current[ :methods_to_call ] << [ method, args ]
      end

      def success( *args )
        add_method_to_call :success, args
      end

      def failure( *args )
        add_method_to_call :failure, args
      end

    end



  end

end
