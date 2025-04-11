class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :ticket, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :total_price

      t.timestamps
    end
  end
end
