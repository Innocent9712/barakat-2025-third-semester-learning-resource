from fastapi import FastAPI
import httpx

app = FastAPI()

@app.get("/")
def read_root():
    return "Welcome"

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/me")
def get_instance_id():
    try:
        # response = httpx.get("http://169.254.169.254/latest/meta-data/instance-id", timeout=2)
        # response.raise_for_status()
        # instance_id = response.text
        instance_id = "i-1234567890"
        return {"instance_id": instance_id}
    except Exception as e:
        return {"error": "Could not fetch instance ID", "details": str(e)}
