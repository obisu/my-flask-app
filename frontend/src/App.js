import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";

import Login from "./pages/auth/Login";
import Dashboard from "./pages/dashboard/Dashboard";
import ProtectedRoute from "./components/auth/ProtectedRoute";
import AddUser from "./pages/AddUser";
import UsersList from "./pages/UsersList";
import EditUser from "./pages/EditUser";
import DbTest from "./pages/DbTest";
import ViewUser from "./pages/ViewUser";   // <-- ADDED

import Layout from "./components/layout/Layout"; // NEW

function App() {
  return (
    <Router>
      <Routes>
        {/* Public Route */}
        <Route path="/" element={<Login />} />

        {/* Protected Routes Wrapped in Layout */}
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <Layout>
                <Dashboard />
              </Layout>
            </ProtectedRoute>
          }
        />

        <Route
          path="/add-user"
          element={
            <ProtectedRoute>
              <Layout>
                <AddUser />
              </Layout>
            </ProtectedRoute>
          }
        />

        <Route
          path="/users"
          element={
            <ProtectedRoute>
              <Layout>
                <UsersList />
              </Layout>
            </ProtectedRoute>
          }
        />

        <Route
          path="/edit-user/:id"
          element={
            <ProtectedRoute>
              <Layout>
                <EditUser />
              </Layout>
            </ProtectedRoute>
          }
        />

        {/* NEW VIEW USER ROUTE */}
        <Route
          path="/view-user/:id"
          element={
            <ProtectedRoute>
              <Layout>
                <ViewUser />
              </Layout>
            </ProtectedRoute>
          }
        />

        <Route
          path="/db-test"
          element={
            <ProtectedRoute>
              <Layout>
                <DbTest />
              </Layout>
            </ProtectedRoute>
          }
        />
      </Routes>
    </Router>
  );
}

export default App;

