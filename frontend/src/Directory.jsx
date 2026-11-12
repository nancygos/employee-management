import { useState, useEffect } from 'react'
import {Link} from 'react-router-dom'
import { API_URL } from './api'

function usd(minor) {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', }).format(minor / 100)
}

export default function Directory() {
    const [q, setQ] = useState('')
    const [search, setSearch] = useState('')
    const [page, setPage] = useState(1)
    const [result, setResult] = useState(null)

    useEffect(()=> {
        const params = new URLSearchParams({ page, per_page: 25 })
        if (search) params.set("q", search)

        fetch(`${API_URL}/api/employees?${params}`).then(res => res.json()).then(setResult)
    }, [search, page])

    function onSubmit(e) {
        e.preventDefault()
        setPage(1)
        setSearch(q)
    }

    return (
        <main>
            <h1>Employees</h1>
            <form onSubmit={onSubmit}>
                <input value = {q} onChange={ (e) => setQ(e.target.value)} placeholder="Search..." />
                <button type="submit">Search</button>
            </form>
            
            {
                !result ? ( <p>Loading...</p> ) : (
                    <>
                        <p>{result.meta.total} employees found</p>
                        <ul>
                            {result.data.map((employee) => (
                                <li key={employee.employee_code}>
                                    <Link to={`/employees/${employee.employee_code}`}>{employee.employee_code}</Link>
                                    {" "}
                                    {employee.first_name} {employee.last_name} — {employee.department}, {usd(employee.salary.usd_annual_amount_minor)}
                              </li>
                            ))}
                        </ul>

                        <div className="pager">
                            <button type="button" disabled={page === 1} onClick={() => setPage(page - 1)}>Previous</button>
                            <button type="button" disabled={page * 25 >= result.meta.total} onClick={() => setPage(page + 1)}>Next</button>
                        </div>
                    </>
                )
            }
        </main>
    )
}
