class Cart < ActiveRecord::Base
  has_many    :items, :class_name => 'CartItem', :dependent => :destroy
  belongs_to  :user
 
  def add_to_cart(cart_item)
    # do we even have anything in our cart?
    if self.items.count > 0
      # readability
      cart_product_ids = self.items.collect{|i| i.product.id}
      puts "THIS IS ITEM: #{cart_item.product.name}"
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