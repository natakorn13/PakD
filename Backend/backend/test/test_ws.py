import asyncio
import websockets

async def test_ws():
    uri = "ws://localhost:8000/ws"  # เปลี่ยนเป็น IP และพอร์ตของคุณ
    try:
        async with websockets.connect(uri) as websocket:
            with open("130.jpeg", "rb") as f:
                image_bytes = f.read()
                print(f"Sending image of size {len(image_bytes)} bytes")
                await websocket.send(image_bytes)

            result = await websocket.recv()
            print("Response from server:", result)

    except Exception as e:
        print("Error during WebSocket communication:", e)

asyncio.run(test_ws())
