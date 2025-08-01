import torch
import torch.nn as nn
from torchvision.models import efficientnet_v2_s
import os

# ✔️ เปลี่ยน path ให้ตรงที่อยู่จริง
MODEL_PATH = "best_oral_disease_model_new.pth"
OUTPUT_PATH = "best_oral_disease_model.ptl"

# ✔️ โหลด checkpoint
checkpoint = torch.load(MODEL_PATH, map_location='cpu')

# ✔️ อ่าน class names จาก checkpoint หรือใช้ default
if 'classes' in checkpoint:
    class_names = checkpoint['classes']
else:
    classifier_weight_shape = None
    for key in checkpoint['model_state_dict'].keys():
        if 'classifier' in key and 'weight' in key:
            classifier_weight_shape = checkpoint['model_state_dict'][key].shape
            break
    if classifier_weight_shape:
        num_classes = classifier_weight_shape[0]
        class_names = [f'class_{i}' for i in range(num_classes)]
    else:
        class_names = ['normal', 'cancer', 'herpes', 'injury', 'ulcer']  # fallback

num_classes = len(class_names)

# ✔️ สร้างโมเดลและโหลดน้ำหนัก
model = efficientnet_v2_s(weights=None)
model.classifier[1] = nn.Linear(model.classifier[1].in_features, num_classes)
model.load_state_dict(checkpoint['model_state_dict'])
model.eval()

# ✔️ สร้าง dummy input สำหรับ tracing
dummy_input = torch.randn(1, 3, 640, 640)

# ✔️ Trace และบันทึกไฟล์ .ptl
traced_script_module = torch.jit.trace(model, dummy_input)
traced_script_module.save(OUTPUT_PATH)

print(f"✅ แปลงสำเร็จ: บันทึกไว้ที่ {OUTPUT_PATH}")
