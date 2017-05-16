# Opalla

Opalla brings Rails way to the front-end. It follows a Rails conventions mixed with a little of Backbone.

It's build on top of `opal` and `opal-rails`.

The project is on beta phase. It's missing:

* Specs
* Tests
* Generators
* Rubocops
* Initializer
* Rake tasks for installation
* ActiveRecord models support

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'opal-rails'
gem 'opalla'
```

Additionally, if you want to use `haml`, add:

```ruby
gem 'opal-haml'
```

And then execute:

    $ bundle

Opalla is a front-end MVC framework. So you want to have this folder structure:

```
your_app
  \_app
    \_assets
      \_javascripts
        \_components
        \_controllers
        \_lib
        \_models
        \_views
```

On the javascript folder, you must rename your `application.js` to `application.rb`

And place this code:

```ruby
require 'opalla'

require_tree './lib'
require_tree './models'
require_tree './components'
require_tree './controllers'
require_tree './views'

Document.ready? do
  Opalla::Router.start
end

```

Lastly, in order to have your routes imported by Opalla, put this on your application layout:

if its `.erb`:

```erb
    <script>
      window.routes = #{ Opalla::Util.routes.html_safe }
    </script>
```

On `.haml`

```haml
    :javascript
      window.routes = #{ Opalla::Util.routes.html_safe }

```

## Usage

### Router & Controllers

It all starts with the Opalla router. It will catch the current URL and direct to the controller/action, exactly like Rails does.

So for example, say you have the following route:

```ruby
get 'pages#index'
```

`Opalla::Router` will instantiate the `PagesController` inside your `javascripts/controller/pages_controller.rb` and trigger the `index` action:

```ruby

class PagesController < ApplicationController

  def index
    el.html 'Hello World!'
  end

end
```

That would replace the `<body>` tag with 'Hello World', as the default `el` for a controller. If you want to change that, you can add `el 'YOU_SELECTOR_HERE'`, in a jQuery selector fashion. So for example:

```ruby

class PagesController < ApplicationController
  el '.main-content'

  def index
    el.html 'Hello World!'
  end

end
```

### Templates

Your Opalla templates will live under `app/assets/javascripts/views`. There you have `./controllers` and `./components`. Note that components templates should start their names with `_`, just like `partials`.

Opalla will automatically have your templates folder added to your server side (Rails). So that means your templates will be rendered server-side and client-side. Yay!

The template will be able to get any access variables (`@variable`) and `methods`. Please note that you have to have both set on server and client sides.

Server-side:

```ruby

class PagesController < ApplicationController
  helper_method :something_awesome

  def index
    @dude = 'Pedro'
  end

  def something_awesome
    'Rails'
  end

end

```

Client-side, note that all methods are available by default, no need to set them as `helper_methods`:

```ruby

class PagesController < ApplicationController
  el '.main-content'

  def index
    @dude = 'Pedro'
    render
  end

  def something_awesome
    'Rails'
  end

end
```

The following `haml` layout would work for both sides:

```haml

  %main
    The dude is called #{@dude}.
    He works with #{something_awesome}

```

### Components

`app/assets/javascripts/components` is where you components live. They will by default render the folder located on `app/assets/javascripts/views/components/_COMPONENT_NAME` (without the '_component' part of the name)

They are instantiated/rendered from the controller layout, like this:

```haml

  %main
    The dude is called #{@dude}.
    He works with #{something_awesome}
    component(:contact_box)

```

That will look for the component `app/assets/javascripts/components/contact_box_component.rb`:

```ruby

class ContactBoxComponent < ApplicationComponent

end
```

#### Model Data

The components can get their data from a model (currently i've been using simple ruby classes). Here's how it goes:

In the controller:

```haml

class PagesController < ApplicationController
  el '.main-content'

  def index
    @dude = 'Pedro'
    @contact_info = ContactInfo.new
    @contact_info.email = 'pedro@pedromaciel.com'
    render
  end

  def something_awesome
    'Rails'
  end

end

```

In the controller template:

```haml

  %main
    The dude is called #{@dude}.
    He works with #{something_awesome}
    component(:contact_box)

```

In the component template:

```haml

  .contact-info
    .email= model.email

```

In the model (`app/assets/javascripts/models/contact_info.rb`):

```
class ContactInfo
  attr_accessor :email

  def initialize
  end
end
```

### Bindings

You can bind data from a model to the component. That will trigger a `#render` action on the component:

```ruby

class ContactBoxComponent < ApplicationComponent
  bind :email, :name

end

```

And that's it! Everytime the model attributes change, the component will be re-rendered.

### Events

Similarly to Backbone, you can add events in the following way:

```ruby

class PagesController < ApplicationController
  el '.main-content'
  events 'click a' => :do_something

  def index
    el.html 'Hello World!'
  end

  def do_something
    alert 'I\'m doing something!'
  end

end

```

You can also provide a `lambda` instead:

```ruby
class PagesController < ApplicationController
  el '.main-content'
  events 'click a' => { alert "I'm doing something!" }

  def index
    el.html 'Hello World!'
  end

end

```
You can also access the targetted object like this:

```ruby
class PagesController < ApplicationController
  el '.main-content'
  events 'click a' => target { alert 'I\'m doing something!' }

  def index
    el.html 'Hello World!'
  end

  def do_something

  end

end

```

Please note that all events have their default behavior prevented by default.


## Development

Fork and make a PR. Or talk to me at `pedro@pedromaciel.com`.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

