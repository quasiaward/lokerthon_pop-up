from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers import ai, email

app = FastAPI(title="행궁다과 API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ai.router)
app.include_router(email.router, prefix="/email")


@app.api_route("/", methods=["GET", "HEAD"])
def health():
    return {"status": "ok"}
