import React, { useEffect, useState } from "react";

function App() {
  const [status, setStatus] = useState("loading...");

  useEffect(() => {
    fetch("/api/health")
      .then((res) => res.json())
      .then((data) => setStatus(data.status))
      .catch(() => setStatus("error"));
  }, []);

  return (
    <div style={{ padding: "2rem", fontFamily: "Arial", fontSize: "1.5rem" }}>
      <h1>Frontend Connected</h1>
      <p>Backend status: {status}</p>
    </div>
  );
}

export default App;
