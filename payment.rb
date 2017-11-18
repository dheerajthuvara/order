module Payment
  def gateway
    ActiveMerchant::Billing::AuthorizeNetGateway.new(
      login: ENV["AUTHORIZE_LOGIN"],
      password: ENV["AUTHORIZE_PASSWORD"]
    )
  end

  def card_type
    length = params[:card_info][:card_number].size

    if length == 15 && number =~ /^(34|37)/
      "AMEX"
    elsif length == 16 && number =~ /^6011/
      "Discover"
    elsif length == 16 && number =~ /^5[1-5]/
      "MasterCard"
    elsif (length == 13 || length == 16) && number =~ /^4/
      "Visa"
    else
      "Unknown"
    end
  end

  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
      number: params[:card_info][:card_number],
      month: params[:card_info][:card_expiration_month],
      year: params[:card_info][:card_expiration_year],
      verification_value: params[:card_info][:cvv],
      first_name: params[:card_info][:card_first_name],
      last_name: params[:card_info][:card_last_name],
      type: card_type
    )
  end
end
