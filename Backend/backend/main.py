from fastapi import FastAPI 
from fastapi.middleware.cors import CORSMiddleware
from api import  websocket


app = FastAPI()

# อนุญาตให้ Flutter เข้าถึง backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # ควรกำหนดเฉพาะ origin ที่ปลอดภัยจริง ๆ
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(websocket.router)
