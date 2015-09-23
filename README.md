# Apiway - Server side 

[**Client side**](https://github.com/4urbanoff/js.apiway)

## Getting started

```r
# Install
$ gem install apiway 

# Create new app
$ apiway new Chat && cd Chat 

# Start server
$ apiway server                  
```

## Database (ActiveRecord)

```r
# Create database
$ bundle exec rake db:create  

# Creating database mirgation                              
$ bundle exec rake db:create_migration NAME=migration_name

# Migrate
$ bundle exec rake db:migrate

# Drop database
$ bundle exec rake db:drop
```

> ### Examples
> ```
> $ bundle exec rake db:create_migration NAME=create_users
> ```
> ```ruby
> # db/mirgations/20140406161815_create_users.rb
> class CreateUsers < ActiveRecord::Migration
>   def change
>     create_table :users do |t|
>       t.string     :token, limit: 32
>       t.string     :name,  limit: 100
>       t.timestamps null: true
>       t.index      :token, unique: true
>     end
>   end
> end
> ```
>
> ```
> $ bundle exec rake db:create_migration NAME=create_messages
> ```
> ```ruby
> # db/mirgations/20140409121731_create_messages.rb
> class CreateMessages < ActiveRecord::Migration
>   def change
>     create_table :messages do |t|
>       t.belongs_to :user
>       t.text       :text
>       t.timestamps null: true
>       t.index      :user_id
>     end
>   end
> end
> ```
> ```
> $ bundle exec rake db:migrate
> ```

## Generator

```r
# Show help
$ apiway generate help

# Create controller
$ apiway generate controller ControllerName

# Create resource
$ apiway generate resource ResourceName

# Create model
$ apiway generate model ModelName
```
## Hierarchy
```r
Base 
|
|---> ApplicationController 
|     |            
|     |---> UsersController <--- Apiway::Controller                          
|                  
|
|---> ApplicationResource 
      |
      |---> UsersResource <----- Apiway::Resource


ActiveRecord::Base
|
|---------> User <-------------- Apiway::Model
```

> ### Examples
> ```ruby
> # app/base/base.rb
> class Base
> 
>   protected
>   
>   def auth?
>     error :auth_error unless client[ :user_id ]
>   end
>   
>   def current_user
>     User.find client[ :user_id ]
>   end
> 
> end
> ```

## Model (this is a simple ActiveRecord model)

```ruby
class Test < ActiveRecord::Base

  include Apiway::Model

  # One class & instance method
  # 
  # - sync  # synchronize model with all the dependent resources
  #         # automatically called in ActiveRecord models 
  #         # after save/destroy

end
```

> ### Examples
> ```
> $ apiway generate model User
> ```
> ```ruby
> # app/models/user.rb
> class User < ActiveRecord::Base
> 
>   include Apiway::Model
> 
>   has_many  :messages, inverse_of: :user
>   validates :name,  length: { in: 3..100 }
>   validates :token, length: { is: 32 }
> 
>   after_initialize do
>     self.token ||= generate_token
>   end
> 
>   def generate_token
>     begin
>       token = SecureRandom.hex 16
>     end while User.exists? token: token
>     token
>   end
> 
> end
> ```
> ```
> $ apiway generate model Message
> ```
> ```ruby
> # app/models/message.rb
> class Message < ActiveRecord::Base
> 
>   include Apiway::Model
> 
>   belongs_to :user, inverse_of: :messages
>   validates  :text, length: { in: 3..500 }
> 
> end
> ```
> ```
> $ apiway generate model Online
> ```
> ```ruby
> # app/models/online.rb
> class Online # < ActiveRecord::Base - db is not required
> 
>   include Apiway::Model
> 
>   def self.value
>     Apiway::Client.all.size
>   end
> 
> end
> ```

## Controller

```ruby
class TestController < ApplicationController

  include Apiway::Controller
  
  #  Class methods:
  #
  #   - Define action
  #
  #       action :new do
  #         < action body >
  #       end
  #
  #   - Before filters:
  #
  #       before_action :action_name
  #       before_action :action_name, only:   :method_name
  #       before_action :action_name, only:   [ :method_name, :method_name ]
  #       before_action :action_name, except: :method_name
  #       before_action :action_name, except: [ :method_name, :method_name ]
  #
  #   - After filters:
  #
  #       after_action  :action_name
  #       after_action  :action_name, only:   :method_name
  #       after_action  :action_name, only:   [ :method_name, :method_name ]
  #       after_action  :action_name, except: :method_name
  #       after_action  :action_name, except: [ :method_name, :method_name ]
  #
  #
  #  Instance methods:
  # 
  #   - client                    # getter to current instance of Apiway::Client
  #   - params                    # getter to options of current request
  #   - error( params )           # stopping controller, call failure callback on client
  #   - trigger( :event, params ) # call trigger event on client with params

end
```
> ### Examples
> ```
> $ apiway generate controller Users
> ```
> ```ruby
> # app/controllers/users.rb
> class UsersController < ApplicationController
> 
>   include Apiway::Controller
> 
>   action :auth_by_name do
>     begin
>       user = User.find_or_create_by! name: params[ :name ]
>     rescue Exception => e
>       error e.message
>     else
>       client[ :user_id ] = user.id
>       user.token
>     end
>   end
> 
>   action :auth_by_token do
>     begin
>       user = User.find_by! token: params[ :token ]
>     rescue
>       nil
>     else
>       client[ :user_id ] = user.id
>     end
>   end
> 
> end
> ```
> ```
> $ apiway generate controller Messages
> ```
> ```ruby
> # app/controllers/messages.rb
> class MessagesController < ApplicationController
> 
>   include Apiway::Controller
> 
>   before_action :auth?
> 
>   action :new do
>     begin
>       current_user.messages.create! text: params[ :text ]
>     rescue Exception => e
>       error e.message
>     else
>       true
>     end
>   end
> 
> 
> end
> ```

## Resource

```ruby
# app/resources/messages.rb
class TestResource < ApplicationResource

  include Apiway::Resource
  
  #  Class methods:
  #
  #   - Define dependencies
  #
  #       depend_on ModelName, ModelName
  #
  #   - Define access check
  #
  #       access do
  #         < body >
  #       end
  #
  #   - Define returned data
  #
  #       data do
  #         < body >
  #       end
  #
  #
  #  Instance methods:
  # 
  #   - client                    # getter to current instance of Apiway::Client
  #   - params                    # getter to resource options
  #   - error( params )           # call resource error event on client

end
```

> ### Examples
> ```
> $ apiway generate resource CurrentUser
> ```
> ```ruby
> # app/resources/current_user.rb
> class CurrentUserResource < ApplicationResource
> 
>   include Apiway::Resource
> 
>   depend_on User
> 
>   access do
>     auth?
>   end
> 
>   data do
>     {
>       id:    current_user.id,
>       name:  current_user.name,
>       token: current_user.token
>     }
>   end
> 
> end
> 
> ```
> ```
> $ apiway generate resource Messages
> ```
> ```ruby
> # app/resources/messages.rb
> class MessagesResource < ApplicationResource
> 
>   include Apiway::Resource
> 
>   depend_on Message, User
> 
>   access do
>     auth?
>   end
> 
>   data do
>     Message.limit( params[ :limit ] ).order( created_at: :desc ).map do |message|
>       {
>         id:   message.id,
>         text: message.text,
>         user: {
>           id:   message.user.id,
>           name: message.user.name
>         }
>       }
>     end
>   end
> 
> end
> 
> ```
> ```
> $ apiway generate resource Online
> ```
> ```ruby
> # app/resources/online.rb
> class OnlineResource < ApplicationResource
> 
>   include Apiway::Resource
> 
>   depend_on Online
> 
>   data do
>     Online.value
>   end
> 
> end
> 
> ```

## Your client events handlers

```ruby
# app/base/client.rb
module Apiway
  class Client

    on_connected do
      # Your handler
    end

    on_message do |message|
      # Your handler
    end

    on_disconnected do
      # Your handler
    end
  end
end
```

> ### Example 
> 
> ```ruby
> #...
>   on_connected do
>     Online.sync
>   end
> 
>   on_disconnected do
>     Online.sync
>   end
> #...
> ```
  