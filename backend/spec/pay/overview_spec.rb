require "rails_helper"

RSpec.describe Pay::Overview do
  def create_employee(code, country_code, department, title, status: "active")
    Employee.create!(
      employee_code: code,
      first_name: "John",
      last_name: "Doe",
      email: "#{code.downcase}@acme.test",
      country_code: country_code,
      department: department,
      status: status,
      hired_on: Date.new(2022, 1, 1),
      job_title: title
    )
  end
  
  it "sums active pay in USD cents and leaves terminated people out" do
    us = create_employee("US123", "US", "Engineering", "Software Engineer")
    us.salaries.create!(effective_on: us.hired_on, currency: "USD", annual_amount_minor: 10_000_000, reason: "hire")
  
    india = create_employee("IN123", "IN", "Sales", "Sales Manager")
    india.salaries.create!(effective_on: india.hired_on, currency: "INR", annual_amount_minor: 100_000_000, reason: "hire")
  
    den = create_employee("DE123", "DE", "Sales", "Sales Manager", status: "terminated")
    den.salaries.create!(effective_on: den.hired_on, currency: "USD", annual_amount_minor: 5_000_000, reason: "hire")
  
    overview = Pay::Overview.new(current_on: Date.new(2026, 11, 6)).to_h
  
    expect(overview[:headcount]).to eq(2)
    expect(overview[:annual_payroll_usd_minor]).to eq(11_200_000)
    expect(overview[:median_salary_usd_minor]).to eq(5_600_000)
    expect(overview[:by_country].map { |row| row[:key] }).to eq(%w[US IN])
    expect(overview[:by_department].map { |row| row[:key] }).to contain_exactly("Engineering", "Sales")
  end
end