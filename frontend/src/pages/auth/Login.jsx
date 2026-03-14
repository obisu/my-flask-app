import React, { useState } from "react";
import { useNavigate } from "react-router-dom";

function Login() {
  const navigate = useNavigate();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setMessage("");
    setLoading(true);

    try {
      const response = await fetch("/api/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
      });

      const data = await response.json();
      console.log("Login response:", data);

      // Match backend response EXACTLY
      if (response.ok && data.message === "Login successful") {
        setMessage("Login successful");

        // Save login state
        localStorage.setItem("loggedIn", "true");

        setTimeout(() => {
          navigate("/dashboard");
        }, 300);
      } else {
        setMessage("Invalid credentials");
      }
    } catch (error) {
      console.error("Login error:", error);
      setMessage("Error connecting to server");
    }

    setLoading(false);
  };

  return (
    <div>
      <h2>Login</h2>

      <form onSubmit={handleLogin}>
        <input
          type="text"
          placeholder="admin"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          required
        />

        <input
          type="password"
          placeholder="••••••"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />

        <button type="submit" disabled={loading}>
          {loading ? "Logging in..." : "Login"}
        </button>
      </form>

      <p>{message}</p>
    </div>
  );
}

export default Login;

