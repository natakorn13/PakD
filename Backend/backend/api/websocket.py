from fastapi import WebSocket, WebSocketDisconnect, APIRouter
from services.ai_service import detect_disease
from typing import List

router = APIRouter()

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def send_personal_message(self, message: dict, websocket: WebSocket):
        await websocket.send_json(message)

    async def broadcast(self, message: dict):
        for connection in self.active_connections:
            await connection.send_json(message)

manager = ConnectionManager()

@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_bytes()
            
            # ตรวจสอบ data ว่าไม่ว่างเปล่า
            if not data:
                await manager.send_personal_message({"status": "error", "message": "Empty data received"}, websocket)
                continue

            result = detect_disease(data)
            await manager.send_personal_message(result, websocket)

    except WebSocketDisconnect:
        manager.disconnect(websocket)
    except Exception as e:
        # กรณีเกิดข้อผิดพลาดอื่นๆ ส่งข้อความ error กลับไป
        await manager.send_personal_message({"status": "error", "message": str(e)}, websocket)
        manager.disconnect(websocket)
