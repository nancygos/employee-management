import { useState, useEffect } from 'react'

function usd(minor) {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', }).format(minor / 100)
}

export default function Overview() {
    const [overview, setOverview] = useState(null)

    useEffect(()=> {
        fetch('http://localhost:3000/api/overview').then(res => res.json()).then(setOverview)
    }, [])

    if(!overview) return <p>Hold tight data is coming your way...</p>

    return (
        <main>
            <h1>Overview</h1>
            <p>{overview.headcount} employees</p>
            <p> Annual payroll: {usd(overview.annual_payroll_usd_minor)}</p>
            <p> Median salary: {usd(overview.median_salary_usd_minor)}</p>

            <h2>By country</h2>
            <ul>
                {overview.by_country.map(row => (
                    <li key={row.key}>
                        {row.key}: {row.headcount} employees, {usd(row.annual_payroll_usd_minor)} annual payroll
                    </li>
                ))}
            </ul>
            <h2>By department</h2>
            <ul>
                {overview.by_department.map(row => (
                    <li key={row.key}>
                        {row.key}: {row.headcount} employees, {usd(row.annual_payroll_usd_minor)} annual payroll
                    </li>
                ))}
            </ul>
        </main>
    )
    
}