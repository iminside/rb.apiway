module Apiway

  module Model



    class << self

      def included( base )
        all << base
        base.class_eval do
          extend  ClassMethods
          include InstanceMethods
        end
      end

      def all
        @all ||= []
      end

    end



    module ClassMethods

      def self.extended( base )
        base.class_eval do

          if self.ancestors.include? ActiveRecord::Base
            after_save    :sync
            after_destroy :sync
          end

        end
      end

      def sync
        Thread.current[ :changed_models ] << self
      end

    end



    module InstanceMethods

      def sync
        self.class.sync
      end

    end



  end

end
