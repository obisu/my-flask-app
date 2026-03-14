#!/bin/bash

echo "Setting up missing frontend/src directories and placeholder files..."

# --- Directories ---
DIRS=(
  "frontend/src/pages"
  "frontend/src/pages/auth"
  "frontend/src/pages/dashboard"
  "frontend/src/components"
  "frontend/src/components/common"
  "frontend/src/components/layout"
  "frontend/src/api"
  "frontend/src/api/auth"
  "frontend/src/api/data"
)

# --- Files (path + content) ---
declare -A FILES

FILES["frontend/src/pages/auth/Login.jsx"]='export default function Login() { return <div>Login Page</div>; }'
FILES["frontend/src/pages/dashboard/Dashboard.jsx"]='export default function Dashboard() { return <div>Dashboard</div>; }'

FILES["frontend/src/components/layout/Navbar.jsx"]='export default function Navbar() { return <nav>Navbar</nav>; }'
FILES["frontend/src/components/common/Button.jsx"]='export default function Button({ children }) { return <button>{children}</button>; }'

FILES["frontend/src/api/client.js"]='export async function api(path, options={}) { return fetch(path, options).then(r => r.json()); }'
FILES["frontend/src/api/auth/login.js"]='import { api } from "../client"; export function login(username, password) { return api("/api/login", { method:"POST", headers:{ "Content-Type":"application/json" }, body: JSON.stringify({ username, password }) }); }'

FILES["frontend/src/api/data/getData.js"]='import { api } from "../client"; export function getData() { return api("/api/data"); }'

# --- Create directories ---
for dir in "${DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "✔ Exists: $dir"
  else
    echo "➕ Creating: $dir"
    mkdir -p "$dir"
  fi
done

# --- Create files only if missing ---
for filepath in "${!FILES[@]}"; do
  if [ -f "$filepath" ]; then
    echo "✔ File exists: $filepath"
  else
    echo "➕ Creating file: $filepath"
    echo "${FILES[$filepath]}" > "$filepath"
  fi
done

echo "Done."

