import { useState, useEffect } from 'react'
import {useParams} from 'react-router-dom'

function money(minor , currency = 'USD') {
    const major = currency === "JPY" ? minor : minor / 100
    return new Intl.NumberFormat("en-US", { style: "currency", currency, }).format(major)
}

export default function EmployeePage() {
    const {employee_code} = useParams()
    const [employee, setEmployee] = useState(null)
    const [form, setForm] = useState({
        effective_on: "",
        currency: "USD",
        annual_amount_minor: 0,
        reason: "merit",
    })

    function load() {
        fetch(`http://localhost:3000/api/employees/${employee_code}`).then(res => res.json()).then((body) => setEmployee(body.data))
    }

    useEffect(load, [employee_code])

    function onSubmit(e) {
        e.preventDefault()
        fetch(`http://localhost:3000/api/employees/${employee_code}/salaries`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(form),
        }).then(load)
    }

    if(!employee) return <p>Loading...</p>
    const current = employee.salaries[0]

    return (
        <main>
            <h1>{employee.first_name} {employee.last_name}</h1>
            <p>{employee.employee_code} · {employee.department} · {employee.job_title}</p>
            <p>Current salary: {money(current.annual_amount_minor, current.currency)}</p>
            <h2>History</h2>
            <ul>
                {employee.salaries.map((salary) => (
                <li key={`${salary.effective_on}-${salary.reason}`}>
                    {salary.effective_on}: {money(salary.annual_amount_minor, salary.currency)} ({salary.reason})
                </li>
                ))}
            </ul>
            <h2>Record a salary change</h2>
            <form onSubmit={onSubmit}>
                <label>Effective date
                    <input type="date" value={form.effective_on} onChange={(event) => setForm({ ...form, effective_on: event.target.value })} />
                </label>
                <label>Currency
                    <input value={form.currency} onChange={(event) => setForm({ ...form, currency: event.target.value })} />
                </label>
                <label>Amount in minor units
                    <input value={form.annual_amount_minor} onChange={(event) => setForm({ ...form, annual_amount_minor: event.target.value })} />
                </label>
                <label>Reason
                    <input value={form.reason} onChange={(event) => setForm({ ...form, reason: event.target.value })} />
                </label>
                <button type="submit">Save</button>
             </form>
        </main>
    )
}