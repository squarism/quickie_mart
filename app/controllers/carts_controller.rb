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
