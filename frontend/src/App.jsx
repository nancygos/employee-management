import { BrowserRouter, NavLink, Routes, Route } from 'react-router-dom'
import Directory from './Directory'
import Overview from "./Overview"
import EmployeePage from "./EmployeePage"

export default function App() {
  return (
    <BrowserRouter>
      <nav>
        <h1><strong>Salary Records</strong></h1> <br />
        <NavLink to="/">Overview</NavLink>
        <span> | </span>
        <NavLink to="/employees">Employees</NavLink>
      </nav>

      <Routes>
        <Route path="/" element={<Overview />} />
        <Route path="/employees" element={<Directory />} />
        <Route path="/employees/:employee_code" element={<EmployeePage />} />
      </Routes>
    </BrowserRouter>
  )
}
