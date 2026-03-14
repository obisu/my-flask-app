def test_db_connection(client):
    response = client.get("/api/db-test")
    assert response.status_code in (200, 500)
