module CurrencyFormatter
  # recusifly splits integer into grooups of 1000's
  def commify_split num, arr=[], factor=1000
    return (arr.empty? ? [0] : arr)  if num.zero?
    units, dec = num.divmod factor
    arr.unshift dec
    commify_split units, arr
  end

  #  return stringifified integer with commas and decmial part. formatted as in currency
  # e.g. 123456 #=> "1,234.56" ... etc.
  def commify num
    units, dec = num.divmod(100)
    arry = commify_split units
    units = arry[1..-1].inject([arry[0].to_s]) {|i, e| i << '%03d' % e}
    "#{units.join(',')}.#{'%02d' % dec}"
  end
  
  
  # given a bigdecimal kind of num, format as dollar currency with commas, et. al.
  # .e.g. 100000099 #=> "$1,000,000.99"
  def dollar_str amt
    return nil if amt.nil?
    "$#{commify amt}"
  end
  
end