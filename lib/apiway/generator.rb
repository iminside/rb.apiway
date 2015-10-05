module Apiway

  module Generator


    class << self

      HANDLERS = {
        create_application:  [ '-a', 'a', 'app'        ],
        create_controller:   [ '-c', 'c', 'controller' ],
        create_resource:     [ '-r', 'r', 'resource'   ],
        create_model:        [ '-m', 'm', 'model'      ],
        help:                [ '-h', 'h', 'help'       ]
      }

      DESC = {
        create_application:  'Creating a new application (`apiway generate app Chat`)',
        create_controller:   'Creating a new controller  (`apiway generate controller Messages`)',
        create_resource:     'Creating a new resource    (`apiway generate resource Messages`)',
        create_model:        'Creating a new model       (`apiway generate model Message`)',
        help:                'Show list of generator commands'
      }

      def run( command = nil, *args )
        return help unless command
        HANDLERS.each { |handler, commands| return send( handler, *args ) if commands.include? command }
        puts "Apiway: Unknown generate command `#{ args.unshift( command ).join " " }`"
      end


      private

      def create_application( name = nil )
        check_name( 'application', name ) do
          source = File.join Apiway.path, 'generator/application'
          target = File.join Dir.pwd, name
          FileUtils.cp_r source, target
          puts "Apiway: Application `#{ name }` created"
          puts "Installing gems"
          exec "cd #{ name } && bundle install"
        end
      end

      def create_controller( name = nil )
        check_name( 'controller', name ) do
          in_root_folder do
            filename  = name.underscore
            classname = filename.camelize
            write "app/controllers/#{ filename }.rb", render( 'controller', classname )
          end
        end
      end

      def create_resource( name = nil )
        check_name( 'resource', name ) do
          in_root_folder do
            filename  = name.underscore
            classname = filename.camelize
            write "app/resources/#{ filename }.rb", render( 'resource', classname )
          end
        end
      end

      def create_model( name = nil )
        check_name( 'model', name ) do
          in_root_folder do
            if name.scan( '_' ).size > 0
              puts 'Apiway: Please do not use an underscore'
            else
              filename  = name.downcase
              classname = name.camelize
              write "app/models/#{ filename }.rb", render( 'model', classname )
            end
          end
        end
      end

      def help( *args )
        puts "\n Apiway generator commands: \n\n"
        HANDLERS.each do |handler, commands|
          puts "  [#{ commands.join( "], [" ) }]".ljust(30) << "# #{ DESC[ handler ] } "
        end
      end

      def check_name( type, name )
        if name then yield
        else puts "Apiway: Enter a name of #{ type }" end
      end

      def in_root_folder
        if Dir.exists?( File.join( Dir.pwd, 'app' ) ) then yield
        else puts 'Apiway: Please go to application root folder' end
      end

      def render( name, classname )
        modelname = classname.chomp 's'
        varname   = modelname.downcase
        ERB.new( File.read( File.join( Apiway.path, 'generator/templates', "#{ name }.tpl" )  ) ).result binding
      end

      def write( path, content )
        File.write( File.join( Dir.pwd, path ), content )
        puts "Apiway: Created: #{ path }"
      end

    end


  end

end
