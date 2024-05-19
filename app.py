from fastapi import FastAPI, File, UploadFile, Response
import cv2
import numpy as np
from ultralytics import YOLO

app = FastAPI()

# Load the saved model
model = YOLO(r"best.onnx")  # Replace with the path to your saved model

@app.post("/detect", response_class=Response)
async def detect(file: UploadFile = File(...)):
    # Read the uploaded image
    image = await file.read()
    nparr = np.frombuffer(image, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # Run the detection
    results = model.predict(source=img, save=False)

    # Process the results (e.g., draw bounding boxes, labels, etc.)
    annotated_image = results[0].plot()

    # Encode the annotated image as JPEG
    _, encoded_image = cv2.imencode(".jpg", annotated_image)

    # Return the encoded image as the response
    return Response(content=encoded_image.tobytes(), media_type="image/jpeg")
