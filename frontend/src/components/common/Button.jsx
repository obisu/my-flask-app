import React from "react";

export default function Button({ children, ...props }) {
  return (
    <button {...props} style={{ padding: "0.5rem 1rem" }}>
      {children}
    </button>
  );
}

