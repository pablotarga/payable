class CreatePayableGatewayPayments < ActiveRecord::Migration
  def up
    create_table :payable_gateway_payments do |t|
      t.string :payable_type
      t.integer :payable_id
      t.datetime :expires_at
      t.string :status
      t.string :config
      t.timestamps
    end
    
    begin
    execute "CREATE UNIQUE INDEX un_index_payable_gateway_payments ON payable_gateway_payments USING btree (payable_id, payable_type) WHERE status <> 'canceled';"
    rescue; end
  end

  def down
    drop_table :payable_gateway_payments
  end
end
