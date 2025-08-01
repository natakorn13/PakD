from services.ai_service import detect_disease

def main():
    with open("mulc.jpg", "rb") as f:
        image_bytes = f.read()

    result = detect_disease(image_bytes)
    print("Result:", result)

if __name__ == "__main__":
    main()
