module Apiway

  module Resource



    class << self

      def included( base )
        base.class_eval do
          extend  ClassMethods
          include InstanceMethods
        end
      end

    end



    module ClassMethods

      def depend_on( *models )
        models.empty? ? @depend_on ||= [] : @depend_on = models
      end

      def access( &block )
        block_given? ? @access = block : @access ||= Proc.new {}
      end

      def data( &block )
        block_given? ? @data = block : @data
      end

    end



    module InstanceMethods

      def initialize( id, client )
        @id     = id
        @client = client
      end

      def set_params( params = {} )
        @params        = params
        @current_error = nil
        self
      end

      def sync_changes( changed_models )
        sync if self.class.depend_on.any? { |dependency| changed_models.include? dependency }
      end

      def sync
        begin
          instance_eval &self.class.access
        rescue ResourceError => e
          sync_error e.params
        else
          sync_data instance_eval &self.class.data
        end
      end


      protected

      attr_reader :client, :params

      def error( params )
        raise ResourceError, params
      end


      private

      def sync_params( error: nil, full: nil, patch: nil )
        params           = { id: @id }
        params[ :error ] = error if error
        params[ :full ]  = full  if full
        params[ :patch ] = patch if patch
        params
      end

      def sync_error( error )
        new_error_json = JSON.generate error, quirks_mode: true
        if !@current_error || @current_error != new_error_json
          @current_error = new_error_json
          @client.trigger RESOURCE::SYNC, sync_params( error: error )
        end
      end

      def sync_data( data )
        @current_error = nil
        new_data_json = JSON.generate data, quirks_mode: true
        if !@current_data || @current_data != new_data_json
          patch         = Diff.new( @current_data, new_data_json ).patch
          patch_json    = JSON.generate patch, quirks_mode: true
          params_sync   = @current_data && patch_json.size < new_data_json.size ? sync_params( patch: patch ) : sync_params( full: data )
          @current_data = new_data_json
          @client.trigger RESOURCE::SYNC, params_sync
        end
      end


    end

  end

end
