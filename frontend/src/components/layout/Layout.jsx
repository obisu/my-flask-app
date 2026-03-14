import React from "react";
import Sidebar from "./Sidebar";
import Topbar from "./Topbar";

export default function Layout({ children }) {
  return (
    <div>
      <Sidebar />
      <Topbar />

      <div
        style={{
          marginLeft: "240px",
          marginTop: "60px",
          padding: "2rem",
          minHeight: "calc(100vh - 60px)",
          background: "#f5f6fa",
        }}
      >
        {children}
      </div>
    </div>
  );
}

