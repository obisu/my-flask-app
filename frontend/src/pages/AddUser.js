import React, { useState } from "react";
import { API_BASE } from "../config";   // <-- ADD THIS

function AddUser() {
  const [name, setName] = useState("");
  const [message, setMessage] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();

    const response = await fetch(`${API_BASE}/api/users`, {   // <-- FIXED
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name }),
    });

    const data = await response.json();
    setMessage(JSON.stringify(data, null, 2));
    setName("");
  };

  return (
    <div style={{ padding: "20px" }}>
      <h1>Add User</h1>

      <form onSubmit={handleSubmit} style={{ maxWidth: "400px" }}>
        <input
          type="text"
          placeholder="Enter name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          style={{
            width: "100%",
            padding: "10px",
            marginBottom: "10px",
            fontSize: "16px",
          }}
        />

        <button
          type="submit"
          style={{
            padding: "10px 20px",
            fontSize: "16px",
            cursor: "pointer",
          }}
        >
          Add
        </button>
      </form>

      {message && (
        <pre
          style={{
            background: "#f5f5f5",
            padding: "10px",
            marginTop: "20px",
            borderRadius: "4px",
          }}
        >
          {message}
        </pre>
      )}
    </div>
  );
}

export default AddUser;

