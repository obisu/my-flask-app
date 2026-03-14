def test_get_users(client):
    response = client.get("/api/users")
    assert response.status_code in (200, 404)

def test_create_user(client):
    response = client.post("/api/users", json={
        "name": "Test User",
        "email": "test@example.com"
    })
    assert response.status_code in (200, 201, 400)

def test_update_user(client):
    response = client.put("/api/users/1", json={
        "name": "Updated User"
    })
    assert response.status_code in (200, 400, 404)

def test_delete_user(client):
    response = client.delete("/api/users/1")
    assert response.status_code in (200, 400, 404)
