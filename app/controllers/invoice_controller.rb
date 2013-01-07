class InvoiceController < ApplicationController
  prepend_before_filter do |c| 
    c.permissions :admin, :index, :show, :delete
    c.titles  :index => "List of Invoices",
              :show => "Invoice"
  end                

  def index
    @invoices = Invoice.find :all
  end

  def show
    add_crumb(Breadcrumb.new("List of Invoices", "invoice", "index"))
    @invoice = Invoice.find params[:id].to_i
  end

  def delete
  end
end
