module ApplicationHelper
  def cart_count
    if User.first.cart == nil
      return 0
    else
      return User.first.cart.items.inject(0) {|total, item| total + item.quantity }
    end
  end
end
