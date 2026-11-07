require 'rails_helper'

RSpec.describe Salary, type: :model do
  def create_employee(hired_on: Date.new(2020, 1, 1))
    Employee.create!(
      employee_code: 'EMP001',
      first_name: 'John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
      country_code: 'US',
      department: 'Engineering',
      job_title: 'Software Engineer',
      status: 'active',
      hired_on: hired_on
    )
  end

  describe ".current_as_of" do
    it "uses the latest effective date on or before the given day" do
      employee = create_employee
      employee.salaries.create!(effective_on: Date.new(2021, 1, 1), currency: "INR", annual_amount_minor: 100_000_00, reason: "hire")
      current = employee.salaries.create!(effective_on: Date.new(2024, 4, 1), currency: "INR", annual_amount_minor: 140_000_00, reason: "merit")
      employee.salaries.create!(effective_on: Date.new(2026, 12, 1), currency: "INR", annual_amount_minor: 180_000_00, reason: "merit")
      found = described_class.current_as_of(Date.new(2026, 11, 6)).where(employee_id: employee.id)
      expect(found.map(&:id)).to eq([current.id])
    end
    it "keeps the later row when two salaries share an effective date" do
      employee = create_employee
      employee.salaries.create!(effective_on: Date.new(2024, 4, 1), currency: "USD", annual_amount_minor: 100_000_00, reason: "hire")
      later = employee.salaries.create!(effective_on: Date.new(2024, 4, 1), currency: "USD", annual_amount_minor: 120_000_00, reason: "adjustment")
      found = described_class.current_as_of(Date.new(2026, 11, 6)).find_by!(employee_id: employee.id)
      expect(found.id).to eq(later.id)
    end
  end
  it "rejects a salary dated before the hire date" do
    employee = create_employee(hired_on: Date.new(2022, 1, 1))
    salary = employee.salaries.new(effective_on: Date.new(2021, 1, 1), currency: "USD", annual_amount_minor: 100_000_00, reason: "hire")
    expect(salary).not_to be_valid
    expect(salary.errors[:effective_on]).to include("can't be before the hire date")
  end
end
