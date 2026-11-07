# ACME Compensation — Requirements

## Goal

Give ACME's HR manager one web tool to maintain salary records for 10,000 employees, and to answer how the organisation pays people, instead of reconstructing that from spreadsheets.

## User

The HR manager. This version has no employee login and no second role.

## In scope

- A directory the HR manager can search by name, email, or employee code, and filter by country, department, and status. Results are paginated.
- An employee page with current annual base pay and the full pay history.
- Recording a pay change (hire, merit, promotion, or adjustment) with an effective date. History is append-only: a new row never overwrites an old one.
- An overview for active employees:
  - headcount being paid
  - annual payroll in USD
  - median annual pay in USD
  - the same totals split by country and by department
- A deterministic seed of 10,000 employees across the countries ACME pays in, stored in local currency.
- Cross-country totals converted with a fixed USD planning rate dated 1 Jan 2026, shown on the overview. A later rate change must not silently rewrite a number already used.

## Out of scope

- Payroll, tax, deductions, and payslips. This records agreed salary, not a bank payment.
- Bonus, equity, and allowances. The brief asks about salary.
- Approval chains, self-service, and SSO. One HR manager on a private deployment.
- Editing or deleting a past salary row. A correction is a new row.
- Live foreign exchange.
- Salary bands and compa-ratio. They do not change the record or the totals.
- Spreadsheet import. The seed stands in for the workbook ACME has today.

## Done when

The HR manager can find a person in the seeded workforce, record a new salary, and read annual payroll and median pay in USD by country and by department. Tests cover current-pay selection, currency conversion, the overview totals, and the API that records a change.
