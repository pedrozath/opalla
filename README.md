# Opalla
![Opalla](opalla.gif)

Opalla brings Rails way to the front-end. It follows a Rails conventions mixed with a little of Backbone.

It's built on top of `opal` and `opal-rails`.

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

```
$ bundle
```

Then run:

```sh

rails g opalla:install

```

Opalla is a front-end MVC framework. So you will to have this folder structure:

```
your_app
  \_app
    \_assets
      \_javascripts
        \_components
        \_controllers
        \_lib
      \_collections
        \_models
        \_views
```

And that’s it! You’re ready to drive Opalla.

## Usage

### Router & Controllers
It all starts with the Opalla router. It will catch the current URL and direct to the controller/action, exactly like Rails does.

So for example, say you have the following route:

```ruby
get 'pages#index'
```

You can generate controllers by running the default Rails controller generator:

```sh

rails g controller pages

```

If you just installed Opalla on your existing app and want to generate Opalla controllers for it, just re-run the command above and leave Rails do the rest! (It won't overwrite anything unless you explicitly ask for).

`Opalla::Router` will automatically import the routes and instantiate the `PagesController` inside your `javascripts/controller/pages_controller.rb` and trigger the `index` action:

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

If you want to share variables with your front-end Opalla MVC, that’s ok. Use the `expose` method automatically available on your server-side controllers:

```ruby

  def index
    expose message: 'Hello World!',
           my_array: [1,2,3]
  end

```

And then you can use the data normally in your views:

```haml
  %p= message
  %p= my_array.join('/')
```

That variables will be automatically available on both sides of your application.

### Components
`app/assets/javascripts/components` is where you components live. They will by default render the folder located on `app/assets/javascripts/views/components/_COMPONENT_NAME` (without the '_component' part of the name)

To create components:

```sh

rails g opalla:component my_component

```

They are instantiated and rendered from the controller layout, like this:

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
The components can get their data from a `Opalla::Model`. Here's how it goes:

First, generate your model:

```sh
  bin/rails g opalla:model contact_info
```

Let’s add a simple attr_accessor:

```ruby
  class Opalla::Model
    attr_accessor :email
  end
```

In the server-side controller you can expose the data, so that will be rendered from the server as default (no one wants blank pages to maybe hurt the SEO):

```ruby
  class PagesController < ApplicationController
    @contact_info = ContactInfo.new
    @contact_info.email = 'pedro@pedromaciel.com'
    expose contact: @contact_info
  end
```

Then, in your server side, you don’t need anything for this case, except for render:

```ruby

class PagesController < ApplicationController
  el '.main-content'

  def index
     render
  end

end

```

In the controller template:

```haml

%main
  component(model: @contact_box)

```

In the component template:

```haml

  .contact-info
    .email= model.email

```

In the model (`app/assets/javascripts/models/contact_info.rb`):

```ruby
class ContactInfo
  def initialize
  end
end
```

### Collection Data

Generate collections:
```sh
  bin/rails g opalla:collection products
```

Opalla will automatically assume that the model is the singular name. So `products` for example is a collection of `product` model. So you have to have the `product` model as well.

When working with collection components, you’ll often want to work with `data-attributes`. Opalla has a nifty way to help you:

Consider you have the following component:
```ruby
  class ProductComponent < ApplicationComponent

  end
```

With the following collection (notice the binding):
```ruby
  class Products < Opalla::Collection
    bind :price, :category
  end
```

On your collection model, you set data:
```ruby
  class Product < Opalla::Model
    data :price, :category, :model_id
  end
```

On your component template:
```haml
  .products
    collection.each |product|
      .product{data=product.data}
    end
  end
```

That will generate data attributes: `data-price`, `data-category`, `data-model-id`, the last enabling you to incorporate events in a very simple fashion

```ruby
  class ProductComponent < ApplicationComponent
    events 'click .product' -> target { buy(collection.find(target)) }
  end
```

That would trigger the buy element providing the `model` as argument. That’s because the `find method` in collections will look for the element or closest ancestor that has a `data-model-id` and return the model itself for you. Really easy!

Check the next chapter to see more ways on how collections can be very useful.

### Bindings

You can bind data from a model or collection to the component. That will trigger a `#render` action on the component:

```ruby

class ContactBoxComponent < ApplicationComponent
  bind :email, :name

end

```

And that's it! Everytime the resource attributes change, being it a `model` or a `collection`, the component will be re-rendered.

#### 2-way binding
If you assign a `[data-bind='ATTRIBUTE_NAME']` to an input element on your template, it will change look for the closest ancestor that has `[data-model-id]` and change its attribute whenever you change the input.

Example:
```haml
.product{data: product.data} # it is expected you set the model data
  input{data-bind: 'name'}
```

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
The project is on beta phase. It's missing:

* Specs
* Tests
* Rubocops
* ActiveRecord models support

Fork and make a PR. Or talk to me at `pedro@pedromaciel.com`.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
