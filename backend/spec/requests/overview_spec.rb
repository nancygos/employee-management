require "rails_helper"

RSpec.describe "Overview API", type: :request do
  it "returns active payroll in USD cents" do
    employee = Employee.create!(
      employee_code: "US123",
      first_name: "John",
      last_name: "Doe",
      email: "john.doe.us123@example.com",
      country_code: "US",
      department: "Engineering",
      status: "active",
      job_title: "Software Engineer",
      hired_on: Date.new(2022, 1, 1),
    )

    employee.salaries.create!(
      effective_on: employee.hired_on,
      currency: "USD",
      annual_amount_minor: 10_000_000,
      reason: "hire"
    )

    get "/api/overview"

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["headcount"]).to eq(1)
    expect(body["annual_payroll_usd_minor"]).to eq(10_000_000)
    expect(body["rate_date"]).to eq("2026-01-01")
  end
end