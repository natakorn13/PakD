from fastapi import APIRouter, UploadFile, File, HTTPException
from services.ai_service import detect_disease  # สมมติไฟล์ AI service ชื่อ ai_service.py

router = APIRouter()

@router.post("/upload")
async def upload_image(file: UploadFile = File(...)):
    try:
        file_bytes = await file.read()  # อ่านไฟล์เป็น bytes

        result = detect_disease(file_bytes)

        if not isinstance(result, dict):
            raise HTTPException(status_code=500, detail="Invalid result from AI service")

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        await file.close()
