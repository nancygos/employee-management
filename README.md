# Employee Salary Records

HR tool to look up 10,000 employees, record an append-only salary change, and read active headcount, annual payroll, and median pay in USD across countries and departments.

**Live app:** https://employee-management-sigma-orpin.vercel.app/  
**API:** https://employee-management-z90m.onrender.com/api/overview  
*(Hosted on Render's free tier — the first request after inactivity may take ~30–40 seconds to wake the API)*

## Requirements

- Ruby 3.3.7
- Node.js 22

## Local setup

### 1. API (`backend/`)

```bash
cd backend
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
