class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :appointment, null: false, foreign_key: true
      t.timestamps
    end
  end
end
