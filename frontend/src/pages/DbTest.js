import { useEffect, useState } from "react";

function DbTest() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    fetch("/api/users")
      .then(res => res.json())
      .then(data => setUsers(data))
      .catch(err => console.error("Error fetching users:", err));
  }, []);

  return (
    <div style={{ padding: "20px" }}>
      <h1>Database Test</h1>
      <pre>{JSON.stringify(users, null, 2)}</pre>
    </div>
  );
}

export default DbTest;

