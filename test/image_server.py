# from flask import Flask, request,jsonify
# import base64
# import io
# import cv2
# #from PIL import Image
# import numpy as np
# import sys

# app = Flask(__name__)

# @app.route('/', methods=['POST'])
# def hello_world():
#     data = request.get_json(force=True)
#     image_data = data['image']
#     imgdata = base64.b64decode(image_data)
    
#     # for show
#     # from PIL import Image
#     # import io
#     # image = Image.open(io.BytesIO(imgdata))
#     # image.show()
    
#     # save image
#     filename = 'leaf.jpg'
#     with open(filename, 'wb') as f:
#         f.write(imgdata)
#         print("Successful")
#     category=processing() 
#     #print(category)
#     return jsonify({"category":category})
#     return 'Receive Successfully and processsed'
 
# def processing():
#     result = {}
#     image = cv2.imread('leaf.jpg')
#     hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
#     lower_green = np.array([40, 40, 40])
#     upper_green = np.array([80, 255, 255])
#     mask = cv2.inRange(hsv, lower_green, upper_green)
#     result1 = cv2.bitwise_and(image, image, mask=mask)
#     average_green = np.mean(result1, axis=(0, 1))
#     if average_green[1] < 50:
#         result = {'status': 'success', 'message': 'Image received and processed successfully in category 1', 'category': 'Category 1'}
#     elif 50 <= average_green[1] < 150:
#         result = {'status': 'success', 'message': 'Image received and processed successfully in category 2', 'category': 'Category 2'}
#     elif 150 <= average_green[1] <= 255:
#         result = {'status': 'success', 'message': 'Image received and processed successfully in category 3', 'category': 'Category 3'}
#     else:
#         result = {'status': 'error', 'message': 'Invalid green value'}
    
#     return result

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', debug=True,port=5000)
 ########################################################################################
# from flask import Flask, request, jsonify
# import base64
# import cv2
# import numpy as np

# app = Flask(__name__)
# calibration_done = False


# chessboardSize = (24, 17)
# frameSize = (1440, 1080)
# criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

# objp = np.zeros((chessboardSize[0] * chessboardSize[1], 3), np.float32)
# objp[:, :2] = np.mgrid[0:chessboardSize[0], 0:chessboardSize[1]].T.reshape(-1, 2)

# objPoints = []  # 3d point in real-world space
# imgPoints = []  # 2d points in the image plane.

# def perform_calibration():
#   global calibration_done
#   global objPoints, imgPoints

#   # Initialize camera
#   cap = cv2.VideoCapture(0)  # Use the appropriate camera index, e.g., 0 for the default camera

#   num_calibration_images = 10  # You can adjust this number based on your preferences

#   for i in range(num_calibration_images):
#       print(f"Capturing calibration image {i + 1}/{num_calibration_images}...")

#       # Capture image from the camera
#       ret, img = cap.read()

#       # Save the captured image to the 'calibration_images' folder
#       cv2.imwrite(f'calibration_images/calibration_img_{i}.png', img)

#       # Display the image for a brief moment (optional)
#       cv2.imshow('Captured Calibration Image', img)
#       cv2.waitKey(1000)

#       # Convert to grayscale
#       gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

#       # Find chessboard corners
#       ret, corners = cv2.findChessboardCorners(gray, chessboardSize, None)

#       if ret:
#           objPoints.append(objp)
#           corners2 = cv2.cornerSubPix(gray, corners, (11, 11), (-1, -1), criteria)
#           imgPoints.append(corners)

#           cv2.drawChessboardCorners(img, chessboardSize, corners2, ret)
#           cv2.imshow('Calibration Image with Corners', img)
#           cv2.waitKey(1000)

#   # Release the camera
#   cap.release()
#   cv2.destroyAllWindows()

#   # Camera Calibration
#   ret, cameraMatrix, dist, rvecs, tvecs = cv2.calibrateCamera(objPoints, imgPoints, frameSize, None, None)

#   print("Camera Calibrated: ", ret)
#   print("\nCamera Matrix:\n", cameraMatrix)
#   print("\nDistortion Parameters:\n", dist)
#   print("\nRotation Vectors:\n", rvecs)
#   print("\nTranslation Vectors:\n", tvecs)

#   calibration_done = True  # Set the calibration status to True

# # Undistortion
# def undistort_image(img):
#     h, w = img.shape[:2]
#     newCameraMatrix, roi = cv2.getOptimalNewCameraMatrix(cameraMatrix, dist, (w, h), 1, (w, h))
#     dst = cv2.undistort(img, cameraMatrix, dist, None, newCameraMatrix)
#     x, y, w, h = roi
#     dst = dst[y:y + h, x:x + w]
#     return dst

# def apply_color_normalization(image):
#     normalized_image = white_balance(hsv_normalization(image))
#     return normalized_image

# @app.route('/', methods=['POST'])
# def hello_world():
#     data = request.get_json(force=True)
#     image_data = data['image']
#     imgdata = base64.b64decode(image_data)

#     # Check if calibration is done
#     global calibration_done
#     if not calibration_done:
#         # If not done, perform calibration
#         perform_calibration()

#     # Load and undistort image
#     image = cv2.imdecode(np.frombuffer(imgdata, np.uint8), cv2.IMREAD_COLOR)
#     undistorted_image = undistort_image(image)

#     # Apply color normalization
#     normalized_image = apply_color_normalization(undistorted_image)

#     # Further processing (e.g., green value analysis)
#     category = processing(normalized_image)
#     return jsonify({"category": category})

# def processing(image):
#     result = {}
#     hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
#     lower_green = np.array([40, 40, 40])
#     upper_green = np.array([80, 255, 255])
#     mask = cv2.inRange(hsv, lower_green, upper_green)
#     result1 = cv2.bitwise_and(image, image, mask=mask)
#     average_green = np.mean(result1, axis=(0, 1))

#     if average_green[1] < 50:
#         result = {'status': 'success', 'message': 'Image received and processed successfully in category 1', 'category': 'Category 1'}
#     elif 50 <= average_green[1] < 150:
#         result = {'status': 'success', 'message': 'Image received and processed successfully in category 2', 'category': 'Category 2'}
#     elif 150 <= average_green[1] <= 255:
#         result = {'status': 'success', 'message': 'Image received and processed successfully in category 3', 'category': 'Category 3'}
#     else:
#         result = {'status': 'error', 'message': 'Invalid green value'}

#     return result

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', debug=True)

################################################
# from flask import Flask, request, jsonify
# import base64
# import cv2
# import numpy as np

# app = Flask(__name__)

# # Assuming that camera_matrix and dist are obtained during calibration
# # You need to replace these with your actual camera matrix and distortion coefficients
# camera_matrix = np.array([[706.94466417 , 0. ,516.12595361],[ 0. ,717.45409302, 287.33655537],[  0.,0. ,1. ]])
# dist = np.array([ 3.01821309e-02, -1.67247050e-01,  1.07340349e-04, -1.92399055e-04, 1.89791896e-01])

# @app.route('/', methods=['POST'])
# def hello_world():
#     data = request.get_json(force=True)
#     image_data = data['image']
#     imgdata = base64.b64decode(image_data)

#     # Save image
#     filename = 'leaf.jpg'
#     with open(filename, 'wb') as f:
#         f.write(imgdata)
#         print("Successful")

#     # Load the image
#     image = cv2.imread('leaf.jpg')

#     # Undistort the image using the camera matrix and distortion coefficients
#     undistorted_image = cv2.undistort(image, camera_matrix, dist)

#     # Further processing
#     category = processing(undistorted_image)

#     return jsonify({"category": category})


# def processing(image):
#     result = {}
#     hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
#     lower_green = np.array([40, 40, 40])
#     upper_green = np.array([80, 255, 255])
#     mask = cv2.inRange(hsv, lower_green, upper_green)
#     result1 = cv2.bitwise_and(image, image, mask=mask)
#     average_green = np.mean(result1, axis=(0, 1))
    
#     if average_green[1] < 50:
#         result = {'status': 'success', 'message': 'Image received and processed successfully in category 1', 'category': 'Category 1'}
#     elif 50 <= average_green[1] < 150:
#         result = {'status': 'success', 'message': 'Image received and processed successfully in category 2', 'category': 'Category 2'}
#     elif 150 <= average_green[1] <= 255:
#         result = {'status': 'success', 'message': 'Image received and processed successfully in category 3', 'category': 'Category 3'}
#     else:
#         result = {'status': 'error', 'message': 'Invalid green value'}

#     return result

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', debug=True)

from flask import Flask, request, jsonify
import base64
import cv2
import numpy as np
import os

app = Flask(__name__)

# Assuming that camera_matrix and dist are obtained during calibration
# You need to replace these with your actual camera matrix and distortion coefficients
camera_matrix = np.array([[706.94466417, 0., 516.12595361], [0., 717.45409302, 287.33655537], [0., 0., 1.]])
dist = np.array([3.01821309e-02, -1.67247050e-01, 1.07340349e-04, -1.92399055e-04, 1.89791896e-01])

@app.route('/', methods=['POST'])
def hello_world():
    data = request.get_json(force=True)

    # Create a folder to store the images
    folder_path = 'images_folder'
    os.makedirs(folder_path, exist_ok=True)

    # Receive and save 10 images
    imagess = []
    for i in range(10):
        image_data = data['images'][i]
        imgdata = base64.b64decode(image_data)

        # Save image with a unique filename
        filename = os.path.join(folder_path, f'image_{i + 1}.jpg')
        with open(filename, 'wb') as f:
            f.write(imgdata)
            print(f"Image {i + 1} saved successfully")

        # Load the image for processing
        image = cv2.imread(filename)
        imagess.append(image)

    # Calculate the average of all 10 images
    average_image = np.mean(imagess, axis=0).astype(np.uint8)

    # Undistort the average image using the camera matrix and distortion coefficients
    undistorted_image = cv2.undistort(average_image, camera_matrix, dist)

    # Further processing
    category = processing(undistorted_image)

    return jsonify({"category": category})


def processing(image):
    result = {}
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    lower_green = np.array([40, 40, 40])
    upper_green = np.array([80, 255, 255])
    mask = cv2.inRange(hsv, lower_green, upper_green)
    result1 = cv2.bitwise_and(image, image, mask=mask)
    average_green = np.mean(result1, axis=(0, 1))

    if average_green[1] < 50:
        result = {'status': 'success', 'message': 'Images received and processed successfully in category 1',
                  'category': 'Category 1'}
    elif 50 <= average_green[1] < 150:
        result = {'status': 'success', 'message': 'Images received and processed successfully in category 2',
                  'category': 'Category 2'}
    elif 150 <= average_green[1] <= 255:
        result = {'status': 'success', 'message': 'Images received and processed successfully in category 3',
                  'category': 'Category 3'}
    else:
        result = {'status': 'error', 'message': 'Invalid green value'}

    return result

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
