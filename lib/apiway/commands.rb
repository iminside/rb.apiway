module Apiway

  module Commands


    class << self

      HANDLERS = {
        version:  [ '-v', 'v', 'version'  ],
        server:   [ '-s', 's', 'server'   ],
        generate: [ '-g', 'g', 'generate' ],
        create:   [ '-n', 'n', 'new'      ],
        help:     [ '-h', 'h', 'help'     ]
      }

      DESC = {
        version:  'Show gem version',
        server:   'Launch thin server, alias for `bundle exec thin start`',
        generate: 'Launch generator, run `apiway generator help` to show commands of generator',
        create:   'Creating a new application',
        help:     'Show list of commands'
      }


      def run( command = nil, *args )
        return help unless command
        HANDLERS.each { |handler, commands| return send( handler, *args ) if commands.include? command }
        puts "Apiway: Unknown command `#{ args.unshift( command ).join " " }`"
      end


      private

      def version( *args )
        puts "Apiway version #{ Apiway::VERSION }"
      end

      def server( *args )
        exec "bundle exec thin start #{ args.join " " }"
      end

      def generate( *args )
        Generator.run *args
      end

      def create( *args )
        generate "app", *args
      end

      def help( *args )
        puts "\n Apiway commands: \n\n"
        HANDLERS.each do |handler, commands|
          puts "  [#{ commands.join( "], [" ) }]".ljust(30) << "# #{ DESC[ handler ] } "
        end
      end

    end


  end

end
