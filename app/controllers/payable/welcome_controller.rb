module Payable 
  class WelcomeController < ApplicationController
    def index
      Order.create(:value => rand(100) * 1.234, :bill_status => 'open') if Order.open.size.zero?
      @orders = Order.order('id DESC').all
    end
  
    def checkout
      @order = Order.find(params[:id])

      begin
        @order.checkout_bill
        redirect_to :controller => "welcome", :action => "json_form", :id => @order.id
      rescue
        flash[:error] = $!.message
        redirect_to root_url
      end
    end
  
    def json_form
      @order = Order.find(params[:id])
    end
  
  end
end