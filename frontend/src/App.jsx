import { BrowserRouter, Link, Routes, Route } from 'react-router-dom'
import Directory from './Directory'
import Overview from "./Overview"

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
      </Routes>
    </BrowserRouter>
  )
}
