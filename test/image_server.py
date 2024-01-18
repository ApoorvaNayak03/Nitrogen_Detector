from flask import Flask, request,jsonify
import base64
import io
import cv2
#from PIL import Image
import numpy as np
import sys

app = Flask(__name__)

@app.route('/', methods=['POST'])
def hello_world():
    data = request.get_json(force=True)
    image_data = data['image']
    imgdata = base64.b64decode(image_data)
    
    # for show
    # from PIL import Image
    # import io
    # image = Image.open(io.BytesIO(imgdata))
    # image.show()
    
    # save image
    filename = 'leaf.jpg'
    with open(filename, 'wb') as f:
        f.write(imgdata)
        print("Successful")
    category=processing() 
    #print(category)
    return jsonify({"category":category})
    return 'Receive Successfully and processsed'
 
def processing():
    result = {}
    image = cv2.imread('leaf.jpg')
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    lower_green = np.array([40, 40, 40])
    upper_green = np.array([80, 255, 255])
    mask = cv2.inRange(hsv, lower_green, upper_green)
    result1 = cv2.bitwise_and(image, image, mask=mask)
    average_green = np.mean(result1, axis=(0, 1))
    if average_green[1] < 50:
        result = {'status': 'success', 'message': 'Image received and processed successfully in category 1', 'category': 'Category 1'}
    elif 50 <= average_green[1] < 150:
        result = {'status': 'success', 'message': 'Image received and processed successfully in category 2', 'category': 'Category 2'}
    elif 150 <= average_green[1] <= 255:
        result = {'status': 'success', 'message': 'Image received and processed successfully in category 3', 'category': 'Category 3'}
    else:
        result = {'status': 'error', 'message': 'Invalid green value'}
    
    return result

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
