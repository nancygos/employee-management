class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :employee_code, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :country_code, null: false
      t.string :department, null: false
      t.string :job_title, null: false
      t.string :status, null: false, default: 'active'
      t.date :hired_on, null: false

      t.timestamps
    end
    add_index :employees, :employee_code, unique: true
    add_index :employees, :email, unique: true
  end
end
