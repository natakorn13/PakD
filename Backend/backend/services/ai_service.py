import torch
import torch.nn as nn
from torchvision import transforms
from PIL import Image
from torchvision.models import efficientnet_v2_s
import io
import os

MODEL_PATH = os.path.join("services", "best_oral_disease_model_new.pth")

# โหลด checkpoint
checkpoint = torch.load(MODEL_PATH, map_location='cpu')

# ดึงชื่อคลาสจาก checkpoint (ถ้ามี)
if 'classes' in checkpoint:
    class_names = checkpoint['classes']
else:
    # ถ้าไม่มี ให้ลองเดาจาก classifier weight shape
    classifier_weight_shape = None
    for key in checkpoint['model_state_dict'].keys():
        if 'classifier' in key and 'weight' in key:
            classifier_weight_shape = checkpoint['model_state_dict'][key].shape
            break
    if classifier_weight_shape:
        num_classes_in_checkpoint = classifier_weight_shape[0]
        class_names = [f'class_{i}' for i in range(num_classes_in_checkpoint)]
    else:
        class_names = ['normal', 'cancer', 'herpes', 'injury', 'ulcer']  # default

num_classes = len(class_names)

# สร้างโมเดล
model = efficientnet_v2_s(weights=None)
model.classifier[1] = nn.Linear(model.classifier[1].in_features, num_classes)

# โหลดน้ำหนักโมเดล
model.load_state_dict(checkpoint['model_state_dict'])
model.eval()

# เตรียม transform pipeline (เหมือนตอน train)
preprocess = transforms.Compose([
    transforms.Resize((640, 640)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225]),
])

# ฟังก์ชันตรวจจับโรคจากภาพ bytes
# ฟังก์ชันตรวจจับโรคจากภาพ bytes
def detect_disease(image_bytes: bytes) -> dict:
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        input_tensor = preprocess(img).unsqueeze(0)

        with torch.no_grad():
            outputs = model(input_tensor)
            probs_tensor = torch.nn.functional.softmax(outputs, dim=1)[0]
            probs = probs_tensor.cpu().numpy()

        pred_idx = probs_tensor.argmax().item()
        original_label = class_names[pred_idx]
        confidence = probs[pred_idx]

        # 🔄 แผนที่รวม label ย่อยให้เป็น label หลัก
        merge_map = {
            'cancer_inner': 'cancer',
            'cancer_outer': 'cancer',
            'herpes_inner': 'herpes',
            'herpes_outer': 'herpes',
        }

        # ใช้ label รวม ถ้าเจอใน map
        merged_label = merge_map.get(original_label, original_label)

        # 🔄 รวม all_probabilities ด้วยการ merge และเอาค่าสูงสุดของแต่ละกลุ่ม
        merged_probs = {}
        for i in range(len(class_names)):
            name = class_names[i]
            prob = probs[i]
            merged_name = merge_map.get(name, name)

            # ถ้า label นี้เคยเจอแล้ว ให้เก็บค่าที่มากที่สุด
            if merged_name in merged_probs:
                merged_probs[merged_name] = max(merged_probs[merged_name], prob)
            else:
                merged_probs[merged_name] = prob

        # แปลงเป็น % และเรียง
        all_probs = {
            k: f"{v * 100:.2f}%" for k, v in sorted(
                merged_probs.items(), key=lambda item: item[1], reverse=True
            )
        }

        return {
            "status": "success",
            "label": merged_label,
            "confidence": f"{confidence * 100:.2f}%",
            "all_probabilities": all_probs
        }

    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }


