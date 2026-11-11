# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

rng = Random.new(2026)
now = Time.current

# min - max lower and upper bounds for the salary in loop
countries = [
  { country_code: "US", currency: "USD", min: 8_000_000, max: 18_000_000 },
  { country_code: "DE", currency: "EUR", min: 7_000_000, max: 15_000_000 },
  { country_code: "GB", currency: "GBP", min: 6_000_000, max: 14_000_000 },
  { country_code: "IN", currency: "INR", min: 120_000_000, max: 300_000_000 },
  { country_code: "SG", currency: "SGD", min: 7_000_000, max: 16_000_000 },
  { country_code: "AE", currency: "AED", min: 20_000_000, max: 45_000_000 },
  { country_code: "JP", currency: "JPY", min: 6_000_000, max: 12_000_000 }
].freeze

departments = {
  "Engineering" => ["Engineer", "Senior Engineer", "Software Engineer"],
  "Sales" => ["Account Executive", "Sales Manager"],
  "People" => ["Recruiter", "HR Partner"],
  "Finance" => ["Accountant", "Analyst"]
}.freeze

first_names = %w[Nancy Noah Mia Liam Zoe Noah Ethan Luna Leo Aria].freeze
last_names = %w[Parker Chung Singh Patel Goswami Muller Rossi Ahmed Tanaka Silva].freeze
department_names = departments.keys

Salary.delete_all
Employee.delete_all

people = 10_000.times.map do |i|
  country = countries[i % countries.size]
  department = department_names[i % department_names.size]
  code = format("%s%05d", country[:country_code], i + 1)
  hired_on = Date.new(2016, 1, 1) + rng.rand(0..3650)
  {
    employee_code: code,
    first_name: first_names[i % first_names.size],
    last_name: last_names[i % last_names.size],
    email: "#{code.downcase}@acme.test",
    country_code: country[:country_code],
    department: department,
    job_title: departments[department][i % 2],
    status: i % 20 == 0 ? "terminated" : "active",
    hired_on: hired_on,
    currency: country[:currency],
    annual_amount_minor: rng.rand(country[:min]..country[:max]),
    created_at: now + i,
    updated_at: now + i
  }
end

Employee.insert_all!(people.map { |person| person.except(:currency, :annual_amount_minor) })
ids = Employee.pluck(:employee_code, :id).to_h
Salary.insert_all!(people.map { |person|
  {
    employee_id: ids.fetch(person[:employee_code]),
    effective_on: person[:hired_on],
    currency: person[:currency],
    annual_amount_minor: person[:annual_amount_minor],
    reason: "hire",
    created_at: person[:created_at],
    updated_at: person[:updated_at]
  }
})