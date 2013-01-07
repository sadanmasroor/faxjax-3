class PromoCode < ActiveRecord::Base
  validates_uniqueness_of :name

  def actual
    if discount_pct.nil?
      0
    else
      discount_pct / 100.0
    end
  end

  def real_start
    TimeFunc::midnight start
  end

  def real_finish
    TimeFunc::twenty3_59_59 finish
  end

  def expired?
    not (real_start .. real_finish).include?(Time.now)
  end

  def apply_rebate?
    (not rebate_flat.nil? and not rebate_flat.zero?) or
    (not rebate_pct.nil? and not rebate_pct.zero?)
  end

  def apply_discount?
    not expired?
  end

  def discount val
    if apply_discount?
      if discount_flat.nil? and discount_pct.nil?
        0
      else
        unless discount_flat.nil? or discount_flat >= val
          discount_flat
        else
          (val * actual).round
        end
      end
    else
      0
    end
  end

  def self.discount code, val
    this = self.find_by_name code
    if this.nil?
      0
    else
      this.discount val
    end
  end

end
