module InvoiceHelper
  class InvoicePresenter
    include ActionView::Helpers::TextHelper
    include CurrencyFormatter
    include UrlHelper


    attr_accessor :invoice
    def initialize invoice
      @invoice = invoice
    end
    
    def id
      @invoice.id
    end
    
    def link
      anchor_for(:controller => "invoice", :action => "show", :id => @invoice.id) do
        "Invoice # #{@invoice.id}"
      end
    end
 
    def tax
      format_dollar @invoice.tax
    end

    def shipping
      format_dollar @invoice.shipping
    end

    def discount
      format_dollar @invoice.discount
    end

    def total
      format_dollar @invoice.total
    end
 
    
    def date_format date
      if date.nil?
        ''
      else
        date.strftime "%m/%d/%Y %H:%M:%S"
      end
    end

    def created_on
      date_format @invoice.created_on
    end

    def updated_at
      date_format @invoice.updated_at
    end

    
    def method_missing name, *args
      result = @invoice.send(name) || ''
      sanitize(result)
    end
    
    private
    def format_dollar dollar
      return dollar_str(0) if dollar.blank?
      dollar_str dollar
    end
  end
  
  class InvoiceDetailPresenter
    include ActionView::Helpers::TextHelper
    include CurrencyFormatter

    attr_accessor :invoice_detail
    def initialize invoice_detail
      @invoice_detail = invoice_detail
    end
    
    def description
      sanitize(@invoice_detail.sign_product.name)
    end
    
    def qty
      @invoice_detail.qty
    end
    
    def price
      dollar_str @invoice_detail.sign_product.price
    end
    
    def discount
      dollar_str 0
    end
    
    def line_price
      dollar_str(@invoice_detail.sign_product.price = @invoice_detail.qty)
    end
    
    private
  end
end
