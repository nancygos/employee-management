import { BrowserRouter, Link, Routes, Route } from 'react-router-dom'
import Directory from './Directory'
import Overview from "./Overview"
import EmployeePage from "./EmployeePage"

export default function App() {
  return (
    <BrowserRouter>
      <nav>
        <Link to="/">Overview</Link>
        <span> | </span>
        <Link to="/employees">Employees</Link>
      </nav>

      <Routes>
        <Route path="/" element={<Overview />} />
        <Route path="/employees" element={<Directory />} />
        <Route path="/employees/:employee_code" element={<EmployeePage />} />
      </Routes>
    </BrowserRouter>
  )
}
