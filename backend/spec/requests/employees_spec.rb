require "rails_helper"

RSpec.describe "Employees API", type: :request do
  def create_employee(code, status: "active", country_code: "US", department: "Engineering", job_title: "Engineer")
    Employee.create!(
      employee_code: code,
      status: status,
      first_name: "Peter",
      last_name: "Parker",
      email: "#{code.downcase}@example.com",
      country_code: country_code,
      department: department,
      job_title: job_title,
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
          "job_title" => "Engineer",
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

  it "append new salary and keep history of previous salaries" do
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
  end

  it "filter empolyees by code, name, email, country code, department, status or job title" do
    us_engineer = create_employee("US347")
    us_engineer.salaries.create!(
      effective_on: Date.new(2020, 1, 1),
      currency: "USD",
      annual_amount_minor: 100_000,
      reason: "hire"
    )
    match = create_employee("IN100", country_code: "IN", department: "Sales")
    match.salaries.create!(
      effective_on: Date.new(2020, 1, 1),
      currency: "INR",
      annual_amount_minor: 100_000,
      reason: "hire"
    )
    former = create_employee("US999", status: "terminated")
    former.salaries.create!(
      effective_on: Date.new(2020, 1, 1),
      currency: "USD",
      annual_amount_minor: 100_000,
      reason: "hire"
    )
    
    get "/api/employees", params: { country_code: "IN", department: "Sales" }
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["data"].map { |e| e["employee_code"] }).to eq(["IN100"])
    expect(body["meta"]["total"]).to eq(1)
    get "/api/employees", params: { status: "terminated" }
    body = JSON.parse(response.body)
    expect(body["data"].map { |e| e["employee_code"] }).to eq(["US999"])
  end

  it "return paginated results" do
    %w[US001 US002 US003].each do |code|
      e = create_employee(code)
      e.salaries.create!(
        effective_on: Date.new(2020, 1, 1),
        currency: "USD",
        annual_amount_minor: 100_000,
        reason: "hire"
      )
    end

    get "/api/employees", params: {page: 2, per_page: 2}
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["data"].map { |e| e["employee_code"] }).to eq(["US003"])
    expect(body["meta"]).to eq({"page" => 2, "per_page" => 2, "total" => 3})
  end

  it "show current salary and full history of salaries" do
    employee = create_employee("US345")
    employee.salaries.create!(
      effective_on: Date.new(2020, 1, 1),
      currency: "USD",
      annual_amount_minor: 100_000,
      reason: "hire"
    )
    employee.salaries.create!(
      effective_on: Date.new(2020, 1, 1),
      currency: "USD",
      annual_amount_minor: 150_000,
      reason: "merit"
    )

    get "/api/employees/US345"
    expect(response).to have_http_status(:ok)

    body = JSON.parse(response.body)
    expect(body["data"]["salaries"].first["annual_amount_minor"]).to eq(150_000)
    expect(body["data"]["salaries"].map { |s| s["reason"] }).to eq(["merit", "hire"])
  end
end