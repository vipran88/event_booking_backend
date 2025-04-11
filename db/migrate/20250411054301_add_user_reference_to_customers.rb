class AddUserReferenceToCustomers < ActiveRecord::Migration[8.0]
  def change
    add_reference :customers, :user, null: false, foreign_key: true
  end
end
