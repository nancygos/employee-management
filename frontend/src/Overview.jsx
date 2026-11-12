import { useState, useEffect } from 'react'

function usd(minor) {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', }).format(minor / 100)
}

const countryName = new Intl.DisplayNames('en', { type: 'region' })

export default function Overview() {
    const [overview, setOverview] = useState(null)

    useEffect(()=> {
        fetch('http://localhost:3000/api/overview').then(res => res.json()).then(setOverview)
    }, [])

    if(!overview) return <p>Hold tight data is coming your way...</p>

    return (
        <main>
            <section className="stats">
                <p><span>Employees</span> {overview.headcount} </p>
                <p><span>Annual payroll</span> {usd(overview.annual_payroll_usd_minor)}</p>
                <p><span>Median salary</span> {usd(overview.median_salary_usd_minor)}</p>
            </section>

            <h2>Country</h2>
            <ul>
                {overview.by_country.map(row => (
                    <li key= {row.key}>
                        <strong>{countryName.of(row.key)}</strong>: {row.headcount} employees, {usd(row.annual_payroll_usd_minor)} annual payroll
                    </li>
                ))}
            </ul>
            <h2>Department</h2>
            <ul>
                {overview.by_department.map(row => (
                    <li key={row.key}>
                        <strong>{row.key}</strong>: {row.headcount} employees, {usd(row.annual_payroll_usd_minor)} annual payroll
                    </li>
                ))}
            </ul>
        </main>
    )   
}