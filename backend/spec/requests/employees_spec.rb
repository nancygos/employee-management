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

  it "fine an employee by employee code" do
    match = create_employee("US345")
    match.salaries.create!(
      effective_on: Date.new(2020, 1, 1),
      currency: "USD",
      annual_amount_minor: 100_000,
      reason: "hire"
    )
    other = create_employee("US346")
    other.salaries.create!(
      effective_on: Date.new(2020, 1, 1),
      currency: "USD",
      annual_amount_minor: 100_000,
      reason: "hire"
    )

    get "/api/employees/US345"
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["data"]["employee_code"]).to eq("US345")
  end

  it "apped new salary and keep history of previous salaries" do
    employee = create_employee("US345")
    employee.salaries.create!(
      effective_on: Date.new(2020, 1, 1),
      currency: "USD",
      annual_amount_minor: 100_000,
      reason: "hire"
    )

    post "/api/employees/US345/salaries", params: {
      effective_on: Date.new(2020, 1, 1),
      currency: "USD",
      annual_amount_minor: 150_000,
      reason: "merit"
    }

    expect(response).to have_http_status(:created)
    body = JSON.parse(response.body)

    expect(employee.salaries.count).to eq(2)
    current_salary = Salary.current_as_of.find_by(employee_id: employee.id)
    expect(current_salary.annual_amount_minor).to eq(150_000)
    expect(current_salary.reason).to eq("merit")
    puts employee.salaries.inspect
  end
end