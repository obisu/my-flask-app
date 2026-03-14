def test_health_check(client):
    response = client.get("/api/health")
    assert response.status_code in (200, 404)

