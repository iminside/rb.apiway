module Apiway

  module LoggerBase


    class << self

      def apiway_log_level( level )
        set_log_level( Log, level || :unknown )
      end

      def activerecord_log_level( level )
        ActiveRecord::Base.logger = level ? set_log_level( new_logger, level ) : false
      end

      def new_logger
        logger           = Logger.new STDOUT
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{ datetime.strftime( "%H:%M:%S" ) } - #{ severity }>  #{ msg }\n"
        end
        logger
      end


      private

      def set_log_level( logger, level )
        logger.level = Logger.const_get level.to_s.upcase
        logger
      end

    end


  end


  Log = LoggerBase::new_logger


end
