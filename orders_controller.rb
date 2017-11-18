class OrdersController < ApplicationController
  include Payment
  before_action :get_cart

  # process order
  def create
    @order = Order.new(order_params)

    # Add items from cart to order's ordered_items association
    @order.ordered_items << @cart.ordered_items

    # Add shipping and tax to order total
    @order.set_total

    # Check if card is valid
    if credit_card.valid?
      charge_credit_card(@order.charge_amount)
    else
      set_error_and_return("Your credit card seems to be invalid")
    end

    if @order.save
      flash[:success] = "You successfully ordered!"
      redirect_to confirmation_orders_path
    else
      set_error_and_return(nil)
    end
  end

  private

  def get_cart
    @cart = Cart.find(session[:cart_id])
    rescue ActiveRecord::RecordNotFound
  end

  def order_params
    params.require(:order).permit!
  end

  def charge_credit_card(charge_amount)
    billing_address = { name: "#{params[:billing_first_name]} #{params[:billing_last_name]}",
                        address1: params[:billing_address_line_1],
                        city: params[:billing_city], state: params[:billing_state],
                        country: 'US',zip: params[:billing_zip],
                        phone: params[:billing_phone] }

    options = { address: {}, billing_address: billing_address }
    # Make the purchase through ActiveMerchant
    response = gateway.purchase(charge_amount, credit_card, options)
    unless response.success?
      set_error_and_return("We couldn't process your credit card")
    end
  end

  def set_error_and_return(msg)
    flash[:error] = "There was a problem processing your order. Please try again."
    @order.errors.add(:error, "#{msg}") if msg.present?
    render :new && return
  end
end
