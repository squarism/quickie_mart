Quickie Mart
============
A 20 minute Rails demo that I used as part of a "What is Ruby on Rails?" talk.  The store was not designed or developed from scratch in 20 minutes but serves as a Cooking Show style demo of what is possible in a very short amount of time.

### Steps to build
These steps are what it took to build this app.  You can checkout this app as a final product but this is intended to walk you through building this project, not starting with it.  All you should need is a Ruby/Rails dev environment and this README.


    A ecommerce store in under 20 minutes with explanations and iterative demonstration.

    # specific to my setup with RVM, if you don't have RVM or know what it is, forget about this step
    rvm gemset use quickie_mart

    # Create your database with
    mysql> create database store_development;
    mysql> grant all on store.* to 'store'@'localhost' identified by 'something';
    mysql> flush privileges;


    # Now create your project
    rails new store

    # if you want, you can switch to mysql.
    # edit Gemfile
    gem 'mysql2'

    # back in shell
    bundle

    #config/database.yml
    development:  
      adapter: mysql2
      host: localhost
      username: store
      password: something
      database: store_development
      pool: 5
      timeout: 5000

    (comment out test and prod for demo)

    rails g scaffold user name:string
    rails g model cart user_id:integer
    rails g model cart_item product_id:integer cart_id:integer
    rails g scaffold product name:string price:float
    rails g model order user_id:integer
    rails g controller carts add clear
    rake db:migrate

    rails s (one console)
    rails c (another console)
    (another bash console in directory)

    # here are our models we're going to work with.  Zero rows right now.
    Product.first
    User.first
    Cart.first
    CartItem.first
    Order.first

    localhost:3000 (show splash page)
    localhost:3000/products (create a new product) - way #1
    Nintendo NES
    $199.99

    way #2 on rails console:
    Product.create(:name => "The Legend of Zelda", :price => 59.99)
    User.create(:name => "Samus")

    But this takes too long.  Better way #3 is to create fixtures:

    # test/fixtures/products.yml
    nes:
      id: 1
      name: Nintendo NES
      price: 199.99

    zelda:
      id: 2
      name: The Legend of Zelda
      price: 59.99

    mario3:
      id: 3
      name: Super Mario Bros. 3
      price: 49.99

    # test/fixtures/users.yml
    samus:
      id: 1
      name: Samus

    (delete cart_items.yml, orders.yml)
    $ rake db:fixtures:load  (this is smart enough to avoid reloading existing records)

    (even better way #4 is to create factories to gen dummy data, like factory girl, not shown)


    class User < ActiveRecord::Base
      has_one :cart
      has_many :orders
    end
    class Cart < ActiveRecord::Base
      has_many    :items, :class_name => 'CartItem', :dependent => :destroy
      belongs_to  :user
    end
    class CartItem < ActiveRecord::Base
      belongs_to :cart
      belongs_to :product
    end
    class Product < ActiveRecord::Base
    end


    (localhost:3000/carts doesn't work, need to fix routes)
    (also localhost:3000 goes to HTML splash page)

    #routes.rb
    Store::Application.routes.draw do
      # order matters, first is highest priority
      resources :products
      resources :users
 
      match 'carts/add/:id' => 'carts#add', :as => :add_to_carts
      match 'carts/clear' => 'carts#clear'
      resources :carts

      root :to => 'products#index'
    end

    (delete public/index.html)


    # app/views/layouts/application.html.erb
    (in <body>)

    <div id="main">
 
         <div id="topNav">         
              <%= link_to "Home", :root %> |
              <%= link_to "Cart (#{User.first.cart.items.count})", carts_path %>
         </div>
    

         <% if notice %>
              <p id="notice"><%= notice %></p>
         <% end %>
    
         <%= yield %>
    
    </div>


    (errors out because we don't have a cart yet, we can use a global helper)
    module ApplicationHelper
      def cart_count
        if User.first.cart == nil
          return 0
        else
          return User.first.cart.items.count
        end
      end
    end

    (now use the helper, change application.html.erb)
    <%= link_to "Cart (#{cart_count})", carts_path %>

    (delete scaffolds.css.scss)

    #app/assets/stylesheets/application.css:
    body { background-color: #5f7395; color: #333; }
    body, p, ol, ul, td {
      font-family: georgia, helvetica, verdana, arial, sans-serif;
      font-size:   12px;
      line-height: 14px;
    }

    table {
      width: 90%;
    }

    table th { text-align:left; }

    table td {
      white-space: nowrap;
      width: auto;
      padding-right: 1em;
      overflow:none;
    }

    a { color: #000; }
    a:visited { color: #666; }
    a:hover { color: #fff; background-color:#000; }

    #main {
         background-color: #fff;
         border: solid #000 1px;
         margin: 5em;
         height: 20em;
         padding: 1em;
         width: 35em;
    }

    #topNav {
         text-align: right;
         /* border: solid #97C36d 1px; */
    }

    #notice {
         background-color: #e1facf;
         border: solid #97C36d 1px;
         padding: 0.5em;
    }


    #app/views/products/index.html.erb

    <h1>Store</h1>
    <table>
    <% @products.each do |product| %>
      <tr>
        <td><%= product.name %></td>
        <td><%= number_to_currency product.price %></td>
        <td><%= link_to 'Add to cart', :controller => 'carts', :action => 'add', :id => product %></td>
      </tr>
    <% end %>
    </table>


    (add product to cart, just show add view, doesn't do anything)

    class CartsController < ApplicationController
      def add
        # slime the multiuser stuff
        @user = User.first
        if @user.cart == nil
          Rails.logger.info "CREATING NEW CART"
          @user.cart = Cart.new
        end
        ci = CartItem.new
        ci.product = Product.find(params[:id])
        @user.cart.items << ci
        redirect_to :products
      end

      def clear
        @user = User.first
        @user.cart.destroy if @user.cart
        flash[:notice] = "Cleared cart."
        redirect_to :products
      end

      def index
        @cart = User.first.cart
      end

    end


    #app/views/carts/index.html.erb
    <h1>Shopping Cart</h1>
    <table>
      <th>Item</th>
      <% if @cart %>
        <% @cart.items.each do |item| %>
        <tr>
          <td><%= item.product.name %></td>
        </tr>
        <% end %>
      <% end %>
    </table>

    <%= link_to "Clear Cart", 'carts/clear' %> | <%= link_to "Checkout" %>


    NOW WE HAVE A PROBLEM!  Adding two of the same products just adds two line items for the same thing.  
    Kind of lame.  What we want is something like this:
      <th>Quantity</th>
      <td>x<%= "<item.quantity goes here>" %></td>

    But if we try that we're going to get this error:
    undefined method `quantity' for #<CartItem:0x007fda13e2ec40>

    So what we want to do is employ a strategy of fat model, skinny controller.
    rails console> CartItem.new
    (see no quantity column, this does not create a row)

    Add column to db/migrate/*create_cart_items.rb
          t.integer :quantity

    rake db:migrate VERSION=0
    rake db:migrate
    rake db:fixtures:load

    rails console> reload!
    rails console> CartItem.new
    (see a quantity column now)


    class Cart < ActiveRecord::Base
      has_many    :items, :class_name => 'CartItem', :dependent => :destroy
      belongs_to  :user

      def add_to_cart(cart_item)
        # do we even have anything in our cart?
        if self.items.count > 0
          # readability
          cart_product_ids = self.items.collect{|i| i.product.id}
          item_product_id = cart_item.product.id

          # do our cart items already have any IDs of item?
          if cart_product_ids.include?(item_product_id)
            # if so, just increase the quantity and don't add a new item
            product_index = self.items.find_index {|i| i.product_id == item_product_id}

            # increment the quantity column
            i = self.items[product_index]
            i.quantity = i.quantity.succ
            i.save
          else
            cart_item.quantity = 1
            self.items << cart_item
          end
        else
          cart_item.quantity = 1
          self.items << cart_item
        end
      end
    end

    class CartsController < ApplicationController
      def add
        # slime the multiuser stuff
        @user = User.first
        if @user.cart == nil
          Rails.logger.info "CREATING NEW CART"
          @user.cart = Cart.new
        end
        cart_item = CartItem.new
        cart_item.product = Product.find params[:id]
        cart_item.cart = @user.cart
        @user.cart.add_to_cart cart_item

        flash[:notice] = "#{cart_item.product.name} added to cart."
        redirect_to products_path
      end

      def clear
        @user = User.first
        @user.cart.destroy if @user.cart
        flash[:notice] = "Cleared cart."
        redirect_to :products
      end

      def index
        @cart = User.first.cart
      end

    end


    (cart total shows number of unique items but not total number of items)
    #application_helper
    return User.first.cart.items.inject(0) {|total, item| total + item.quantity }

    (show /products.json)
    (show /products.xml)
    (just follow example)
    format.xml { render xml: @products }


    (too verbose?)
    format.xml { render xml: @products, :except => [:created_at, :updated_at] }
    format.xml { render xml: @products, :only => [:name, :price] }






    (note to myself: noisy crap about assets serving from rails 3.1 and new ruby)
    gem 'thin'
    bundle install
    rails s thin

    initializers/quiet_assets.rb
    Rails.application.assets.logger = Logger.new('/dev/null')
    Rails::Rack::Logger.class_eval do
      def before_dispatch_with_quiet_assets(env)
        before_dispatch_without_quiet_assets(env) unless env['PATH_INFO'].index("/assets/") == 0
      end
      alias_method_chain :before_dispatch, :quiet_assets
    end