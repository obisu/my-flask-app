import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { API_BASE } from "../config";   // <-- ADD THIS

function EditUser() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [name, setName] = useState("");
  const [loading, setLoading] = useState(true);

  // ----------------------------------------------------
  // Load the user by ID
  // Backend returns: { users: [...] }
  // ----------------------------------------------------
  useEffect(() => {
    async function loadUser() {
      try {
        const res = await fetch(`${API_BASE}/api/users`);   // <-- FIXED
        const data = await res.json();

        const user = data.users.find((u) => u.id === Number(id));
        if (user) {
          setName(user.name);
        }
      } catch (err) {
        console.error("Failed to load user:", err);
      } finally {
        setLoading(false);
      }
    }

    loadUser();
  }, [id]);

  // ----------------------------------------------------
  // Save updated user
  // Correct backend route: PUT /api/users/<id>
  // ----------------------------------------------------
  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      await fetch(`${API_BASE}/api/users/${id}`, {   // <-- FIXED
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name }),
      });

      alert("User updated successfully");

      // Redirect back to UsersList
      navigate("/users");
    } catch (err) {
      console.error("Failed to update user:", err);
      alert("Error updating user");
    }
  };

  if (loading) return <p style={{ padding: "20px" }}>Loading...</p>;

  return (
    <div style={{ padding: "20px" }}>
      <h1>Edit User</h1>

      <form onSubmit={handleSubmit}>
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          style={{ padding: "10px", width: "300px" }}
        />
        <button
          style={{
            marginLeft: "10px",
            padding: "10px 20px",
            cursor: "pointer",
          }}
        >
          Save
        </button>
      </form>
    </div>
  );
}

export default EditUser;

