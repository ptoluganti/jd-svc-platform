import { useEffect, useState } from 'react'

export default function App() {
  const [status, setStatus] = useState({})

  useEffect(() => {
    setStatus({ ready: true })
  }, [])

  return (
    <div style={{ fontFamily: 'sans-serif', padding: 16 }}>
      <h1>JD Service Platform</h1>
      <p>React UI is running.</p>
      <pre>{JSON.stringify(status, null, 2)}</pre>
    </div>
  )
}
