class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.decimal :value, :precision => 9, :scale => 2
      t.string :bill_status

      t.timestamps
    end
  end
end
