class AddTicketsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets do |t|
      t.string  :external_id
      t.boolean :imported, default: false

      t.timestamps
    end
  end
end
