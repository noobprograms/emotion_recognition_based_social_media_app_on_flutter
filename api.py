import base64
import io
from flask import Flask, request,jsonify
import json
import cv2
import numpy as np
from tensorflow.keras.models import load_model

app = Flask(__name__)
loaded_model = load_model(r"C:\Users\DELL\Downloads\sentimentAn_model.h5")
@app.route("/",methods = ['GET'])
def Home():
    return "My Flask backend"
@app.route('/senti', methods=['POST'])
def senti():
    imgb = json.loads(request.data)
    
    base64Image = imgb['image']
    imageBytes = base64.b64decode(base64Image)
    

    nparr = np.frombuffer(imageBytes,np.uint8)
    
    image = nparr.reshape((3072, 450))

    
    detector = cv2.CascadeClassifier(r'C:\Users\DELL\AppData\Local\Programs\Python\Python37\Lib\site-packages\cv2\data\haarcascade_frontalface_default.xml')
    faces = detector.detectMultiScale(image, 1.1, 5)
    if len(faces) == 0:
        # Verify the image array
        if len(image.shape) == 3 and image.shape[2] == 3:
        # Save the image
            try:
                cv2.imwrite('image.jpg', image)
                print("Image saved successfully.")
            except Exception as e:
                print("Error saving image:", str(e))
        else:
            print("Invalid image array format.")
            return 'No face detected'
    else:
        # Extract the first face
        (x,y,w,h) = faces[0]
        face = image[y:y+h,x:x+w]
        # Resize the face to match the model input shape
        resized_face = cv2.resize(face, (48, 48)) / 255.0
        # Reshape the face to match the model input shape
        input_data = np.reshape(resized_face, (1, 48, 48, 1))
        # Get the prediction
        prediction = loaded_model.predict(input_data)
        # Get the emotion label
        emotionArr = ['Angry', 'Disgust', 'Fear', 'Happy', 'Sad', 'Surprise', 'Neutral']
        emotion = emotionArr[np.argmax(prediction)]
        return emotion
    
    return jsonify({'message':'image is reached'})

    
    # Convert the image bytes to a numpy array

    # Convert the image to grayscale
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    # Detect faces in the image
    detector = cv2.CascadeClassifier(r'C:\Users\DELL\AppData\Local\Programs\Python\Python37\Lib\site-packages\cv2\data\haarcascade_frontalface_default.xml')
    print("apun is working")
    

if __name__ == '__main__':
    app.run(debug=False,host = '0.0.0.0')
