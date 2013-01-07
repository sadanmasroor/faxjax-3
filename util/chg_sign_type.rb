def chg_sign_type old, knew
  SignProduct.find(:all, :conditions=>["sign_type=?", old]).each do |sp|
    begin
      sp.sign_type = knew
      sp.save!
      puts "SignProduct #{sp.id} changed #{old}, #{knew}"
    rescue Exception => e
      puts "SignProduct #{sp.id} save failed"
      puts "Error SignProduct " + e.message

      begin
        sp.tax = 0
        sp.shipping_price = 0
        sp.save!
        puts "SignProduct #{sp.id} finally saved"
      rescue Exception => e
        puts "Error SignProduct #{sp.id} " + e.message
      end
    end
  end
  
  puts "SignProduct done"
  
  Sign.find(:all, :conditions => ["sign_type=?", old]).each do |s|
    begin
      s.sign_type = knew
      s.save!
      puts "Sign #{s.id} changed #{old}, #{knew}"
    rescue Exception => e
      puts "Sign #{s.id} save failed"
      puts "Error SignProduct " + e.message
    end
  end
  puts "Sign done"
end

chg_sign_type "SaleSign", "For Sale"
chg_sign_type "RentSign", "For Rent"
chg_sign_type "LeaseSign", "For Lease"

#  uncomment below to restore

# chg_sign_type "For Sale", "SaleSign"
# chg_sign_type "For Rent", "RentSign"
# chg_sign_type "For Lease", "LeaseSign"