class Api::SalariesController < ApplicationController
  def create
    employee = Employee.find_by(employee_code: params[:employee_id])
    return render json: {error: "Employee not found"}, status: :not_found if employee.nil?

    salary = Salary.create!(
      effective_on: params[:effective_on],
      currency: params[:currency],
      annual_amount_minor: params[:annual_amount_minor],
      reason: params[:reason],
      employee_id: employee.id
    )
    render json: {data: salary}, status: :created
  end
end