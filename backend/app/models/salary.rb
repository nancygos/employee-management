class Salary < ApplicationRecord
  belongs_to :employee

  validate :not_before_hire_date

  def self.current_as_of(date = Date.current)
    salaries = Salary.where(effective_on: ..date).order(effective_on: :desc, id: :desc)
    newest_salary = salaries.pluck(:employee_id, :id).uniq(&:first)
    current_salary_ids = newest_salary.map(&:last)
    
    Salary.where(id: current_salary_ids)
  end

  private

  def not_before_hire_date
    return if effective_on.blank? || employee.nil? || employee.hired_on.blank? || effective_on >= employee.hired_on
    if effective_on < employee.hired_on
      errors.add(:effective_on, "can't be before the hire date")
    end
  end

end
