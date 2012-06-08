class Order < ActiveRecord::Base
  attr_accessible :value, :bill_status

  ADDR_STRUCT = Struct.new(:address, :number, :complement, :district, :city_name, :state_name, :country_name, :zip, :phone)
  ADDR_DUMMY  = ADDR_STRUCT.new('Rua de Teste', '3345', 'apto 101', 'Centro', 'Caxias', 'RS', 'BRA', '93345-201', '(51)8888-3333')
  
  USER_STRUCT = Struct.new(:id, :name, :birthday, :id_card, :email, :billing_address)
  USER_DUMMY  = USER_STRUCT.new(1, "Dummy User", Date.new(1990, 1, 1), '11111111111', 'dummy@dummyco.com', ADDR_DUMMY)
  
  def self.open
    where("bill_status = 'open'")
  end
  
  payable :user => lambda{ USER_DUMMY },
          :name => "Ordem de Pedido"
end
