module Apiway

  class Application < Sinatra::Base


    set root:              File.expand_path( '.' )
    set static:            true
    set apiway_log:        true
    set active_record_log: true
    set log_level:         :debug
    set database_file:     File.join( root, 'config/database.yml' )


    register Sinatra::ActiveRecordExtension


    configure :development do
      register Sinatra::Reloader
      also_reload File.join( root, '**/*.rb' )
      # also_reload File.join( Apiway.path, '**/*.rb' )
    end


    get '*' do
      request.websocket? ? request.websocket{ |ws| Apiway::Client.new ws } : pass
    end


    %W(
      lib/**/*.rb
      config/environments/#{ environment.to_s }.rb
      config/initializers/**/*.rb
      app/base/**/*.rb
      app/controllers/application.rb
      app/resources/application.rb
      app/**/*.rb
    )
    .map{ |path| Dir[ File.join( root, path ) ] }
    .flatten.uniq.each{ |path| require path }


    LoggerBase::apiway_log_level       apiway_log
    LoggerBase::activerecord_log_level activerecord_log


    def self.tasks
      require 'sinatra/activerecord/rake'
    end


  end

end
