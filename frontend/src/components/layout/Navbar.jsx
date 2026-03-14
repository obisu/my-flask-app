import React from "react";
import { Link, useLocation } from "react-router-dom";

export default function Navbar() {
  const location = useLocation();
  const loggedIn = localStorage.getItem("loggedIn") === "true";

  // Hide navbar on login page
  if (location.pathname === "/") {
    return null;
  }

  return (
    <nav style={{ padding: "1rem", background: "#eee" }}>
      {loggedIn ? (
        <>
          <Link to="/dashboard" style={{ marginRight: "1rem" }}>
            Dashboard
          </Link>
          <Link to="/logout">Logout</Link>
        </>
      ) : (
        <Link to="/">Login</Link>
      )}
    </nav>
  );
}

