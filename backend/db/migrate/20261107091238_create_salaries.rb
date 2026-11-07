class CreateSalaries < ActiveRecord::Migration[8.0]
  def change
    create_table :salaries do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :effective_on, null: false
      t.string :currency, null: false
      t.integer :annual_amount_minor, null: false
      t.string :reason, null: false

      t.timestamps
    end
    add_index :salaries, [:employee_id, :effective_on]
  end
end
