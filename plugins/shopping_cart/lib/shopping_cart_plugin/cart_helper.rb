module ShoppingCartPlugin::CartHelper

  include ActionView::Helpers::NumberHelper

  def sell_price(product)
    return 0 if product.price.nil?
    product.discount ? product.price_with_discount : product.price
  end

  def get_price(product, environment)
    float_to_currency_cart(sell_price(product), environment)
  end

  def get_total(items, environment)
    float_to_currency_cart(items.map { |id, quantity| sell_price(Product.find(id)) * quantity}.sum, environment)
  end

  def items_table(items, environment, by_mail = false)
    '<table id="cart-items-table" cellpadding="2" cellspacing="0"
    border="'+(by_mail ? '1' : '0')+'"
    style="'+(by_mail ? 'border-collapse:collapse' : '')+'">' +
    content_tag('tr',
                content_tag('th', _('Item name')) +
                content_tag('th', by_mail ? '&nbsp;#&nbsp;' : '#') +
                content_tag('th', _('Price'))
    ) +
    items.map do |id, quantity|
      product = Product.find(id)
      quantity_opts = { :class => 'cart-table-quantity' }
      quantity_opts.merge!({:align => 'center'}) if by_mail
      price_opts = {:class => 'cart-table-price'}
      price_opts.merge!({:align => 'right'}) if by_mail
      content_tag('tr',
                  content_tag('td', product.name) +
                  content_tag('td', quantity, quantity_opts ) +
                  content_tag('td', get_price(product, environment), price_opts )
                 )
    end.join("\n") +
    content_tag('th', _('Total:'), :colspan => 2, :class => 'cart-table-total-label') +
    content_tag('th', get_total(items, environment), :class => 'cart-table-total-value') +
    '</table>'
  end

  private

  def float_to_currency_cart(value, environment)
    number_to_currency(value, :unit => environment.currency_unit, :separator => environment.currency_separator, :delimiter => environment.currency_delimiter, :format => "%u %n")
  end

end
