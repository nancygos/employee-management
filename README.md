# Employee salary records

HR tool to look up 10,000 employees, record a salary change and read active headcount, annual payroll and median pay in USD.

## Requirements

- Ruby 3.3.7
- Node.js 22

## API

From backend/:

bundle i
rails db:prepare
rails db:seed
rails server

The API listens on http://localhost:3000. 
db:seed loads 10,000 employees. 
Tests: rspec

## Web app

From frontend/, in a second terminal:

npm install
npm run dev

Open http://localhost:5173. Both processes have to be running. The browser calls the API on port 3000
