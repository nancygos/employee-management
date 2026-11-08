module Pay
  class Overview
    def initialize(current_on: Date.current)
      @current_on = current_on
    end

    def to_h
      pay_rows = active_pay_rows
      usd_amounts = pay_rows.map { |pay_row| pay_row[:usd_minor] }
      {
        current_on: @current_on,
        rate_date: Rates::AS_OF_DATE,
        headcount: pay_rows.size,
        annual_payroll_usd_minor: usd_amounts.sum,
        median_salary_usd_minor: median(usd_amounts),
        by_country: group_pay(pay_rows, :country_code),
        by_department: group_pay(pay_rows, :department)
      }
    end

    private

    def active_pay_rows
      Salary.current_as_of(@current_on).joins(:employee).where(employees: { status: "active" })
        .pluck("employees.country_code", "employees.department", "salaries.currency", "salaries.annual_amount_minor")
        .map do |country_code, department, currency, amount_minor|
          {
            country_code: country_code,
            department: department,
            usd_minor: Rates.to_usd(amount_minor, currency)
          }
        end
    end

    def group_pay(pay_rows, attribute)
      pay_rows.group_by { |pay_row| pay_row[attribute] }.map do |group_name, rows_in_group|
        usd_amounts = rows_in_group.map { |pay_row| pay_row[:usd_minor] }
        {
          key: group_name,
          headcount: rows_in_group.size,
          annual_payroll_usd_minor: usd_amounts.sum,
          median_salary_usd_minor: median(usd_amounts)
        }
      end.sort_by { |group| -group[:annual_payroll_usd_minor] }
    end

    def median(amounts)
      sorted = amounts.sort
      return 0 if sorted.empty?

      midpoint = sorted.length / 2
      if sorted.length.odd?
        sorted[midpoint]
      else
        (sorted[midpoint - 1] + sorted[midpoint]) / 2.0
      end
    end
  end
end