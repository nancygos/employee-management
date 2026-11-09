class Api::EmployeesController < ApplicationController
  def index
    per_page = params[:per_page] || 25
    total_employees = Employee.where(status: "active")
    employees = total_employees.limit(per_page)

    current_salary = Salary.current_as_of.where(employee_id: employees.map(&:id)).index_by(&:employee_id)

    data = employees.map do |e|
      curr_salary = current_salary[e.id]
      {
        employee_code: e.employee_code,
        first_name: e.first_name,
        last_name: e.last_name,
        email: e.email,
        country_code: e.country_code,
        department: e.department,
        job_title: e.job_title,
        hired_on: e.hired_on,
      }.merge(
        salary: {
          annual_amount_minor: curr_salary.annual_amount_minor,
          currency: curr_salary.currency,
          usd_annual_amount_minor: Pay::Rates.to_usd(curr_salary.annual_amount_minor, curr_salary.currency)
        }
      )
    end
    meta = {page: 1, per_page: per_page, total: total_employees.count}

    render json: {data: data, meta: meta}
  end

end