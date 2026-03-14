import React, { useEffect, useState } from "react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

import { API_BASE } from "../../config";

export default function Dashboard() {
  // ---------------------------------------------
  // State: User Activity (Step 1)
  // ---------------------------------------------
  const [activityData, setActivityData] = useState([]);

  // ---------------------------------------------
  // State: System Health (Step 2)
  // ---------------------------------------------
  const [systemHealth, setSystemHealth] = useState(null);

  // ---------------------------------------------
  // State: Dashboard Summary (Step 3)
  // ---------------------------------------------
  const [summary, setSummary] = useState(null);

  // ---------------------------------------------
  // Fetch real user activity data
  // ---------------------------------------------
  useEffect(() => {
    async function fetchActivity() {
      try {
        const res = await fetch(`${API_BASE}/api/stats/user-activity`);
        const data = await res.json();

        // Force correct weekday order
        const orderedDays = ["Mon", "Tue", "Wed", "Thu", "Fri"];

        const formatted = orderedDays.map((day) => ({
          day,
          users: data.activity[day] || 0,
        }));

        setActivityData(formatted);
      } catch (err) {
        console.error("Failed to load activity data:", err);
      }
    }

    fetchActivity();
  }, []);

  // ---------------------------------------------
  // Fetch system health data
  // ---------------------------------------------
  useEffect(() => {
    async function fetchHealth() {
      try {
        const res = await fetch(`${API_BASE}/api/stats/system-health`);
        const data = await res.json();
        setSystemHealth(data);
      } catch (err) {
        console.error("Failed to load system health:", err);
      }
    }

    fetchHealth();
  }, []);

  // ---------------------------------------------
  // Fetch dashboard summary data
  // ---------------------------------------------
  useEffect(() => {
    async function fetchSummary() {
      try {
        const res = await fetch(`${API_BASE}/api/stats/summary`);
        const data = await res.json();
        setSummary(data);
      } catch (err) {
        console.error("Failed to load summary:", err);
      }
    }

    fetchSummary();
  }, []);

  return (
    <div>
      <h1 style={{ marginBottom: "1.5rem" }}>Dashboard</h1>

      {/* ---------------------------------------------
          Summary Cards (now fully real)
         --------------------------------------------- */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(250px, 1fr))",
          gap: "1.5rem",
          marginBottom: "2rem",
        }}
      >
        <Card
          title="Total Users"
          value={summary ? summary.total_users : "Loading..."}
        />

        <Card
          title="Backend Status"
          value={summary ? summary.backend_status : "Loading..."}
        />

        <Card
          title="Frontend Status"
          value={summary ? summary.frontend_status : "Loading..."}
        />

        <Card
          title="Database Status"
          value={summary ? summary.database_status : "Loading..."}
        />

        <Card
          title="DB Latency (ms)"
          value={
            systemHealth && systemHealth.db_latency_ms !== null
              ? systemHealth.db_latency_ms
              : "—"
          }
        />
      </div>

      {/* ---------------------------------------------
          User Activity Chart (real data)
         --------------------------------------------- */}
      <div
        style={{
          background: "white",
          padding: "1.5rem",
          borderRadius: "8px",
          boxShadow: "0 2px 6px rgba(0,0,0,0.1)",
        }}
      >
        <h3 style={{ marginBottom: "1rem" }}>User Activity</h3>

        <div style={{ width: "100%", height: "300px" }}>
          <ResponsiveContainer>
            <LineChart data={activityData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="day" />
              <YAxis />
              <Tooltip />
              <Line
                type="monotone"
                dataKey="users"
                stroke="#007bff"
                strokeWidth={3}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}

function Card({ title, value }) {
  return (
    <div
      style={{
        background: "white",
        padding: "1.5rem",
        borderRadius: "8px",
        boxShadow: "0 2px 6px rgba(0,0,0,0.1)",
      }}
    >
      <h4 style={{ marginBottom: "0.5rem" }}>{title}</h4>
      <p style={{ fontSize: "1.8rem", fontWeight: "bold" }}>{value}</p>
    </div>
  );
}

