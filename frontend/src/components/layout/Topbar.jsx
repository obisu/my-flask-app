import React from "react";

export default function Topbar() {
  return (
    <div
      style={{
        height: "60px",
        background: "#ffffff",
        borderBottom: "1px solid #ddd",
        display: "flex",
        alignItems: "center",
        padding: "0 1.5rem",
        marginLeft: "240px",
        position: "fixed",
        top: 0,
        right: 0,
        left: "240px",
        zIndex: 10,
      }}
    >
      <h3 style={{ margin: 0 }}>AItechskill Playground</h3>
    </div>
  );
}

