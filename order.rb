class Order < ApplicationRecord

  def set_total
    case shipping_method
    when 'ground'
      total = taxed_total.round(2)
    when 'two-day'
      total = taxed_total + (15.75).round(2)
    when "overnight"
      total = taxed_total + (25).round(2)
    end
  end

  def charge_amount
    (total.to_f * 100).to_i
  end

  before_create :set_order_status
  after_create :destroy_cart_and_send_mail

  private

  def set_order_status
    self.order_status = 'processed'
  end

  def destroy_cart_and_send_mail
    # get rid of cart
    Cart.destroy(ordered_items.first.cart)
    # send order confirmation email
    OrderMailer.order_confirmation(billing_email, id).deliver_later
  end
end
