require "rails_helper"

RSpec.describe "Employees API", type: :request do
  def create_employee(code, status: "active")
    Employee.create!(
      employee_code: code,
      status: status,
      first_name: "Peter",
      last_name: "Parker",
      email: "#{code.downcase}@example.com",
      country_code: "US",
      department: "Engineering",
      job_title: "Software Engineer",
      hired_on: Date.new(2020, 1, 1),
    )
  end

  it "lists active employees and their current salary" do
    active_employee = create_employee("US345")
    active_employee.salaries.create!(
      effective_on: Date.new(2020, 1, 1),
      currency: "USD",
      annual_amount_minor: 100_000,
      reason: "hire",
    )

    get "/api/employees"
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body).to eq({
      "data" => [
        {
          "employee_code" => "US345",
          "first_name" => "Peter",
          "last_name" => "Parker",
          "email" => "us345@example.com",
          "country_code" => "US",
          "department" => "Engineering",
          "job_title" => "Software Engineer",
          "hired_on" => "2020-01-01",
          "salary" => {
            "annual_amount_minor" => 100_000,
            "currency" => "USD",
            "usd_annual_amount_minor" => 100_000
          }
        }
      ],
      "meta" => {
        "page" => 1,
        "per_page" => 25,
        "total" => 1,
      }
    })
  end
end