import React from "react";
import { Link, useNavigate } from "react-router-dom";

export default function Sidebar() {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem("loggedIn");
    navigate("/");
  };

  return (
    <div
      style={{
        width: "240px",
        height: "100vh",
        background: "#1e1e2f",
        color: "white",
        padding: "1rem",
        position: "fixed",
        left: 0,
        top: 0,
      }}
    >
      <h2 style={{ marginBottom: "2rem", fontSize: "1.4rem" }}>
        AItechskill
      </h2>

      <nav style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
        <Link style={linkStyle} to="/dashboard">Dashboard</Link>
        <Link style={linkStyle} to="/add-user">Add User</Link>
        <Link style={linkStyle} to="/users">View Users</Link>
        <Link style={linkStyle} to="/db-test">Database Test</Link>

        <button
          onClick={handleLogout}
          style={{
            marginTop: "2rem",
            padding: "0.5rem 1rem",
            background: "#d9534f",
            border: "none",
            borderRadius: "4px",
            color: "white",
            cursor: "pointer",
            textAlign: "left",
          }}
        >
          Logout
        </button>
      </nav>
    </div>
  );
}

const linkStyle = {
  color: "white",
  textDecoration: "none",
  fontSize: "1.1rem",
};

