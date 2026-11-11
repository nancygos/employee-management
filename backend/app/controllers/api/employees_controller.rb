class Api::EmployeesController < ApplicationController
  def index
    pages = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 25).to_i
    total_employees = Employee.where(status: params[:status] || "active")

    if params[:q].present?
      total_employees = total_employees.where("employee_code LIKE :term OR first_name LIKE :term OR last_name LIKE :term OR email LIKE :term", term: "%#{params[:q]}%")
    end

    total_employees = total_employees.where(country_code: params[:country_code]) if params[:country_code].present?
    total_employees = total_employees.where(department: params[:department]) if params[:department].present?
    total_employees = total_employees.where(job_title: params[:job_title]) if params[:job_title].present?
    employees = total_employees.order(created_at: :asc).offset((pages - 1) * per_page).limit(per_page)
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
    meta = {page: pages, per_page: per_page, total: total_employees.count}

    render json: {data: data, meta: meta}
  end

  def show
    employee = Employee.find_by(employee_code: params[:id])
    return render json: {error: "Employee not found"}, status: :not_found if employee.nil?

    salaries = employee.salaries.order(effective_on: :desc, id: :desc)
    
    render json: {data: {
      employee_code: employee.employee_code,
      first_name: employee.first_name,
      last_name: employee.last_name,
      email: employee.email,
      country_code: employee.country_code,
      department: employee.department,
      job_title: employee.job_title,
      hired_on: employee.hired_on,
      salaries: salaries.map { |s|
        {
          annual_amount_minor: s.annual_amount_minor,
          currency: s.currency,
          reason: s.reason,
          effective_on: s.effective_on
        }
      }
    }}
  end

end