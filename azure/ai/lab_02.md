### Lab 2(Analyze images with azure ai vision):

- https://github.com/MicrosoftLearning/mslearn-ai-vision/tree/main/Instructions/Exercises

#### Analyze image:

##### .env

```dotenv
AI_SERVICE_ENDPOINT=https://azure-ai-vision-demo-mm.openai.azure.com/
AI_SERVICE_KEY=9590wHeILzgCapXkJ2CEmWiA5AFyWFoSrS6MZpOu55hmsMDLXIZHJQQJ99AKACYeBjFXJ3w3AAAAACOGPgEO
```

##### image-analysis.py

```cmd
pip install azure-ai-vision-imageanalysis==1.0.0b3 matplotlib pillow
```

```python
from dotenv import load_dotenv
import os
from PIL import Image, ImageDraw
import sys
from matplotlib import pyplot as plt
from azure.core.exceptions import HttpResponseError
import requests
import json
# import namespaces
from azure.ai.vision.imageanalysis import ImageAnalysisClient
from azure.ai.vision.imageanalysis.models import VisualFeatures
from azure.core.credentials import AzureKeyCredential


def main():
    global cv_client

    try:
        # Get Configuration Settings
        load_dotenv()
        ai_endpoint = os.getenv('AI_SERVICE_ENDPOINT')
        ai_key = os.getenv('AI_SERVICE_KEY')

        # Get image
        image_file = 'images/street.jpg'
        if len(sys.argv) > 1:
            image_file = sys.argv[1]

        with open(image_file, "rb") as f:
            image_data = f.read()

        # Authenticate Azure AI Vision client
        cv_client = ImageAnalysisClient(
            endpoint=ai_endpoint,
            credential=AzureKeyCredential(ai_key)
        )


        # Analyze image
        AnalyzeImage(image_file, image_data, cv_client)

        # Background removal
        BackgroundForeground(ai_endpoint, ai_key, image_file)

    except Exception as ex:
        print(ex)


def AnalyzeImage(image_filename, image_data, cv_client):
    print('
Analyzing image...')

    try:
        # Get result with specified features to be retrieved
        result = cv_client.analyze(
            image_data = image_data,
            visual_features = [
                VisualFeatures.CAPTION,
                VisualFeatures.DENSE_CAPTIONS,
                VisualFeatures.TAGS,
                VisualFeatures.OBJECTS,
                VisualFeatures.PEOPLE
            ]
        )

    except HttpResponseError as e:
        print(f"Status code: {e.status_code}")
        print(f"Reason: {e.reason}")
        print(f"Message: {e.error.message}")

    # Display analysis results
    # Get image captions
    if result.caption is not None:
        print("
Caption:")
        print(" Caption: '{}' (confidence: {:.2f}%)".format(result.caption.text, result.caption.confidence * 100))

    # Get image dense captions
    if result.dense_captions is not None:
        print("
Dense Captions:")
        for caption in result.dense_captions.list:
            print(" Caption: '{}' (confidence: {:.2f}%)".format(caption.text, caption.confidence * 100))

    if result.tags is not None:
        print(" Tags:")
        for tag in result.tags.list:
            print("   '{}', Confidence {:.2f}".format(tag.name, tag.confidence * 100.0))

    if result.objects is not None:
        print(" Objects in image:")
        image = Image.open(image_filename)
        fig = plt.figure(figsize = (image.width/100, image.height/ 100))
        plt.axis('off')
        draw = ImageDraw.Draw(image)
        color = 'cyan'
        for detected_object in result.objects.list:
            # Print object name
            print(" {} (confidence: {:.2f}%)".format(detected_object.tags[0].name, detected_object.tags[0].confidence * 100))

            # Draw object bounding box
            r = detected_object.bounding_box
            bounding_box = ((r.x, r.y), (r.x + r.width, r.y + r.height))
            draw.rectangle(bounding_box, outline=color, width=3)
            plt.annotate(detected_object.tags[0].name,(r.x, r.y), backgroundcolor=color)

        # Save annotated image
        plt.imshow(image)
        plt.tight_layout(pad=0)
        outputfile = 'objects.jpg'
        fig.savefig(outputfile)
        print('  Results saved in', outputfile)

    # Get people in the image# Get people in the image
    if result.people is not None:
        print("
People in image:")

        # Prepare image for drawing
        image = Image.open(image_filename)
        fig = plt.figure(figsize=(image.width/100, image.height/100))
        plt.axis('off')
        draw = ImageDraw.Draw(image)
        color = 'cyan'

        for detected_people in result.people.list:
            # Draw object bounding box
            r = detected_people.bounding_box
            bounding_box = ((r.x, r.y), (r.x + r.width, r.y + r.height))
            draw.rectangle(bounding_box, outline=color, width=3)

            # Return the confidence of the person detected
            #print(" {} (confidence: {:.2f}%)".format(detected_people.bounding_box, detected_people.confidence * 100))

        # Save annotated image
        plt.imshow(image)
        plt.tight_layout(pad=0)
        outputfile = 'people.jpg'
        fig.savefig(outputfile)
        print('  Results saved in', outputfile)

def BackgroundForeground(endpoint, key, image_file):
    # Define the API version and mode
    api_version = "2023-02-01-preview"
    mode="backgroundRemoval" # Can be "foregroundMatting" or "backgroundRemoval"

    # Remove the background from the image or generate a foreground matte
    # Remove the background from the image or generate a foreground matte
    print('
Removing background from image...')

    url = "{}computervision/imageanalysis:segment?api-version={}&mode={}".format(endpoint, api_version, mode)

    headers= {
        "Ocp-Apim-Subscription-Key": key,
        "Content-Type": "application/json"
    }

    image_url="https://github.com/MicrosoftLearning/mslearn-ai-vision/blob/main/Labfiles/01-analyze-images/Python/image-analysis/{}?raw=true".format(image_file)

    body = {
        "url": image_url,
    }

    response = requests.post(url, headers=headers, json=body)

    image=response.content
    with open("background.png", "wb") as file:
        file.write(image)
    print('  Results saved in background.png
')



if __name__ == "__main__":
    main()

```

#### image classification:

```powershell
$storageAcct = '<storageAccount>'
(Get-Content training-images/training_labels.json) -replace '<storageAccount>', $storageAcct | Out-File training-images/training_labels.json
```

```json
{
  "images": [
    {
      "id": 1,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164823.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164823.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164823.jpg",
      "date_captured": "2023-12-07T22:52:56.1086527Z"
    },
    {
      "id": 2,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164932.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164932.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164932.jpg",
      "date_captured": "2023-12-07T22:52:56.1086381Z"
    },
    {
      "id": 3,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164957.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164957.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164957.jpg",
      "date_captured": "2023-12-07T22:52:56.1087048Z"
    },
    {
      "id": 4,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165219.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165219.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165219.jpg",
      "date_captured": "2023-12-07T22:52:56.1086937Z"
    },
    {
      "id": 5,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164926jpg.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164926jpg.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164926jpg.jpg",
      "date_captured": "2023-12-07T22:52:56.1086765Z"
    },
    {
      "id": 6,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164925.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164925.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164925.jpg",
      "date_captured": "2023-12-07T22:52:56.1086545Z"
    },
    {
      "id": 7,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164901.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164901.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164901.jpg",
      "date_captured": "2023-12-07T22:52:56.108699Z"
    },
    {
      "id": 8,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165236.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165236.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165236.jpg",
      "date_captured": "2023-12-07T22:52:56.1087188Z"
    },
    {
      "id": 9,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164760.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164760.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164760.jpg",
      "date_captured": "2023-12-07T22:52:56.1087144Z"
    },
    {
      "id": 10,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165108.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165108.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165108.jpg",
      "date_captured": "2023-12-07T22:52:56.1086463Z"
    },
    {
      "id": 11,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165220.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165220.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165220.jpg",
      "date_captured": "2023-12-07T22:52:56.1087029Z"
    },
    {
      "id": 12,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165232.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165232.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165232.jpg",
      "date_captured": "2023-12-07T22:52:56.1086564Z"
    },
    {
      "id": 13,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164918.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164918.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164918.jpg",
      "date_captured": "2023-12-07T22:52:56.1086359Z"
    },
    {
      "id": 14,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165152.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165152.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165152.jpg",
      "date_captured": "2023-12-07T22:52:56.1086681Z"
    },
    {
      "id": 15,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165157.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165157.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165157.jpg",
      "date_captured": "2023-12-07T22:52:56.1087245Z"
    },
    {
      "id": 16,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164830.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164830.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164830.jpg",
      "date_captured": "2023-12-07T22:52:56.108666Z"
    },
    {
      "id": 17,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165112.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165112.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165112.jpg",
      "date_captured": "2023-12-07T22:52:56.1086872Z"
    },
    {
      "id": 18,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165021.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165021.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165021.jpg",
      "date_captured": "2023-12-07T22:52:56.1086916Z"
    },
    {
      "id": 19,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165001.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165001.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165001.jpg",
      "date_captured": "2023-12-07T22:52:56.1086442Z"
    },
    {
      "id": 20,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164952.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164952.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164952.jpg",
      "date_captured": "2023-12-07T22:52:56.1086703Z"
    },
    {
      "id": 21,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165026.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165026.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165026.jpg",
      "date_captured": "2023-12-07T22:52:56.1086635Z"
    },
    {
      "id": 22,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164947.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164947.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164947.jpg",
      "date_captured": "2023-12-07T22:52:56.1086895Z"
    },
    {
      "id": 23,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165002.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165002.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165002.jpg",
      "date_captured": "2023-12-07T22:52:56.1086831Z"
    },
    {
      "id": 24,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164958.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164958.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164958.jpg",
      "date_captured": "2023-12-07T22:52:56.1086614Z"
    },
    {
      "id": 25,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164936.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164936.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164936.jpg",
      "date_captured": "2023-12-07T22:52:56.1086341Z"
    },
    {
      "id": 26,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165115.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165115.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165115.jpg",
      "date_captured": "2023-12-07T22:52:56.108701Z"
    },
    {
      "id": 27,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164811.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164811.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164811.jpg",
      "date_captured": "2023-12-07T22:52:56.1087166Z"
    },
    {
      "id": 28,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165027.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165027.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165027.jpg",
      "date_captured": "2023-12-07T22:52:56.1086507Z"
    },
    {
      "id": 29,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164804.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164804.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164804.jpg",
      "date_captured": "2023-12-07T22:52:56.1086321Z"
    },
    {
      "id": 30,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165047.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165047.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165047.jpg",
      "date_captured": "2023-12-07T22:52:56.1086851Z"
    },
    {
      "id": 31,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165016.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165016.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165016.jpg",
      "date_captured": "2023-12-07T22:52:56.1087066Z"
    },
    {
      "id": 32,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164759.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164759.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164759.jpg",
      "date_captured": "2023-12-07T22:52:56.1087109Z"
    },
    {
      "id": 33,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164819.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164819.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164819.jpg",
      "date_captured": "2023-12-07T22:52:56.1087209Z"
    },
    {
      "id": 34,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165126.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165126.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165126.jpg",
      "date_captured": "2023-12-07T22:52:56.1086263Z"
    },
    {
      "id": 35,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165234.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165234.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165234.jpg",
      "date_captured": "2023-12-07T22:52:56.1086404Z"
    },
    {
      "id": 36,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164919.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164919.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164919.jpg",
      "date_captured": "2023-12-07T22:52:56.1086486Z"
    },
    {
      "id": 37,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165147.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165147.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165147.jpg",
      "date_captured": "2023-12-07T22:52:56.1086969Z"
    },
    {
      "id": 38,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165202.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165202.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165202.jpg",
      "date_captured": "2023-12-07T22:52:56.1086813Z"
    },
    {
      "id": 39,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165223.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165223.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165223.jpg",
      "date_captured": "2023-12-07T22:52:56.1087088Z"
    },
    {
      "id": 40,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165046.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165046.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165046.jpg",
      "date_captured": "2023-12-07T22:52:56.1086724Z"
    },
    {
      "id": 41,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165020.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165020.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165020.jpg",
      "date_captured": "2023-12-07T22:52:56.1086794Z"
    },
    {
      "id": 42,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165033.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165033.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165033.jpg",
      "date_captured": "2023-12-07T22:52:56.1086746Z"
    },
    {
      "id": 43,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165132.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165132.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165132.jpg",
      "date_captured": "2023-12-07T22:52:56.1087227Z"
    },
    {
      "id": 44,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_165008.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_165008.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_165008.jpg",
      "date_captured": "2023-12-07T22:52:56.1086582Z"
    },
    {
      "id": 45,
      "width": 1024,
      "height": 768,
      "file_name": "IMG_20200229_164851.jpg",
      "coco_url": "AmlDatastore://fruit/IMG_20200229_164851.jpg",
      "absolute_url": "https://<storageAccount>.blob.core.windows.net/fruit/IMG_20200229_164851.jpg",
      "date_captured": "2023-12-07T22:52:56.1086301Z"
    }
  ],
  "annotations": [
    {
      "id": 1,
      "category_id": 1,
      "image_id": 1,
      "area": 0.0
    },
    {
      "id": 2,
      "category_id": 1,
      "image_id": 2,
      "area": 0.0
    },
    {
      "id": 3,
      "category_id": 3,
      "image_id": 3,
      "area": 0.0
    },
    {
      "id": 4,
      "category_id": 2,
      "image_id": 4,
      "area": 0.0
    },
    {
      "id": 5,
      "category_id": 1,
      "image_id": 5,
      "area": 0.0
    },
    {
      "id": 6,
      "category_id": 1,
      "image_id": 6,
      "area": 0.0
    },
    {
      "id": 7,
      "category_id": 1,
      "image_id": 7,
      "area": 0.0
    },
    {
      "id": 8,
      "category_id": 2,
      "image_id": 8,
      "area": 0.0
    },
    {
      "id": 9,
      "category_id": 1,
      "image_id": 9,
      "area": 0.0
    },
    {
      "id": 10,
      "category_id": 2,
      "image_id": 10,
      "area": 0.0
    },
    {
      "id": 11,
      "category_id": 2,
      "image_id": 11,
      "area": 0.0
    },
    {
      "id": 12,
      "category_id": 2,
      "image_id": 12,
      "area": 0.0
    },
    {
      "id": 13,
      "category_id": 1,
      "image_id": 13,
      "area": 0.0
    },
    {
      "id": 14,
      "category_id": 2,
      "image_id": 14,
      "area": 0.0
    },
    {
      "id": 15,
      "category_id": 2,
      "image_id": 15,
      "area": 0.0
    },
    {
      "id": 16,
      "category_id": 1,
      "image_id": 16,
      "area": 0.0
    },
    {
      "id": 17,
      "category_id": 2,
      "image_id": 17,
      "area": 0.0
    },
    {
      "id": 18,
      "category_id": 3,
      "image_id": 18,
      "area": 0.0
    },
    {
      "id": 19,
      "category_id": 3,
      "image_id": 19,
      "area": 0.0
    },
    {
      "id": 20,
      "category_id": 3,
      "image_id": 20,
      "area": 0.0
    },
    {
      "id": 21,
      "category_id": 3,
      "image_id": 21,
      "area": 0.0
    },
    {
      "id": 22,
      "category_id": 3,
      "image_id": 22,
      "area": 0.0
    },
    {
      "id": 23,
      "category_id": 3,
      "image_id": 23,
      "area": 0.0
    },
    {
      "id": 24,
      "category_id": 3,
      "image_id": 24,
      "area": 0.0
    },
    {
      "id": 25,
      "category_id": 1,
      "image_id": 25,
      "area": 0.0
    },
    {
      "id": 26,
      "category_id": 2,
      "image_id": 26,
      "area": 0.0
    },
    {
      "id": 27,
      "category_id": 1,
      "image_id": 27,
      "area": 0.0
    },
    {
      "id": 28,
      "category_id": 3,
      "image_id": 28,
      "area": 0.0
    },
    {
      "id": 29,
      "category_id": 1,
      "image_id": 29,
      "area": 0.0
    },
    {
      "id": 30,
      "category_id": 3,
      "image_id": 30,
      "area": 0.0
    },
    {
      "id": 31,
      "category_id": 3,
      "image_id": 31,
      "area": 0.0
    },
    {
      "id": 32,
      "category_id": 1,
      "image_id": 32,
      "area": 0.0
    },
    {
      "id": 33,
      "category_id": 1,
      "image_id": 33,
      "area": 0.0
    },
    {
      "id": 34,
      "category_id": 2,
      "image_id": 34,
      "area": 0.0
    },
    {
      "id": 35,
      "category_id": 2,
      "image_id": 35,
      "area": 0.0
    },
    {
      "id": 36,
      "category_id": 1,
      "image_id": 36,
      "area": 0.0
    },
    {
      "id": 37,
      "category_id": 2,
      "image_id": 37,
      "area": 0.0
    },
    {
      "id": 38,
      "category_id": 2,
      "image_id": 38,
      "area": 0.0
    },
    {
      "id": 39,
      "category_id": 2,
      "image_id": 39,
      "area": 0.0
    },
    {
      "id": 40,
      "category_id": 3,
      "image_id": 40,
      "area": 0.0
    },
    {
      "id": 41,
      "category_id": 3,
      "image_id": 41,
      "area": 0.0
    },
    {
      "id": 42,
      "category_id": 3,
      "image_id": 42,
      "area": 0.0
    },
    {
      "id": 43,
      "category_id": 2,
      "image_id": 43,
      "area": 0.0
    },
    {
      "id": 44,
      "category_id": 3,
      "image_id": 44,
      "area": 0.0
    },
    {
      "id": 45,
      "category_id": 1,
      "image_id": 45,
      "area": 0.0
    }
  ],
  "categories": [
    {
      "id": 1,
      "name": "apple"
    },
    {
      "id": 2,
      "name": "orange"
    },
    {
      "id": 3,
      "name": "banana"
    }
  ]
}
```

#### object detection:

##### test-detector:

```python
from azure.cognitiveservices.vision.customvision.prediction import CustomVisionPredictionClient
from msrest.authentication import ApiKeyCredentials
from matplotlib import pyplot as plt
from PIL import Image, ImageDraw, ImageFont
import numpy as np
import os

def main():
    from dotenv import load_dotenv

    try:
        # Get Configuration Settings
        load_dotenv()
        prediction_endpoint = os.getenv('PredictionEndpoint')
        prediction_key = os.getenv('PredictionKey')
        project_id = os.getenv('ProjectID')
        model_name = os.getenv('ModelName')

        # Authenticate a client for the training API
        credentials = ApiKeyCredentials(in_headers={"Prediction-key": prediction_key})
        prediction_client = CustomVisionPredictionClient(endpoint=prediction_endpoint, credentials=credentials)

        # Load image and get height, width and channels
        image_file = 'produce.jpg'
        print('Detecting objects in', image_file)
        image = Image.open(image_file)
        h, w, ch = np.array(image).shape

        # Detect objects in the test image
        with open(image_file, mode="rb") as image_data:
            results = prediction_client.detect_image(project_id, model_name, image_data)

        # Create a figure for the results
        fig = plt.figure(figsize=(8, 8))
        plt.axis('off')

        # Display the image with boxes around each detected object
        draw = ImageDraw.Draw(image)
        lineWidth = int(w/100)
        color = 'magenta'
        for prediction in results.predictions:
            # Only show objects with a > 50% probability
            if (prediction.probability*100) > 50:
                # Box coordinates and dimensions are proportional - convert to absolutes
                left = prediction.bounding_box.left * w
                top = prediction.bounding_box.top * h
                height = prediction.bounding_box.height * h
                width =  prediction.bounding_box.width * w
                # Draw the box
                points = ((left,top), (left+width,top), (left+width,top+height), (left,top+height),(left,top))
                draw.line(points, fill=color, width=lineWidth)
                # Add the tag name and probability
                plt.annotate(prediction.tag_name + ": {0:.2f}%".format(prediction.probability * 100),(left,top), backgroundcolor=color)
        plt.imshow(image)
        outputfile = 'output.jpg'
        fig.savefig(outputfile)
        print('Results saved in ', outputfile)
    except Exception as ex:
        print(ex)

if __name__ == "__main__":
    main()

```

```dotenv
PredictionEndpoint=YOUR_PREDICTION_ENDPOINT
PredictionKey=YOUR_PREDICTION_KEY
ProjectID=YOUR_PROJECT_ID
ModelName=fruit-detector
```

##### Train detector:

```dotenv
TrainingEndpoint=YOUR_TRAINING_ENDPOINT
TrainingKey=YOUR_TRAINING_KEY
ProjectID=YOUR_PROJECT_ID
```

```python
from azure.cognitiveservices.vision.customvision.training import CustomVisionTrainingClient
from azure.cognitiveservices.vision.customvision.training.models import ImageFileCreateBatch, ImageFileCreateEntry, Region
from msrest.authentication import ApiKeyCredentials
import time
import json
import os

def main():
    from dotenv import load_dotenv
    global training_client
    global custom_vision_project

    try:
        # Get Configuration Settings
        load_dotenv()
        training_endpoint = os.getenv('TrainingEndpoint')
        training_key = os.getenv('TrainingKey')
        project_id = os.getenv('ProjectID')

        # Authenticate a client for the training API
        credentials = ApiKeyCredentials(in_headers={"Training-key": training_key})
        training_client = CustomVisionTrainingClient(training_endpoint, credentials)

        # Get the Custom Vision project
        custom_vision_project = training_client.get_project(project_id)

        # Upload and tag images
        Upload_Images('images')
    except Exception as ex:
        print(ex)



def Upload_Images(folder):
    print("Uploading images...")

    # Get the tags defined in the project
    tags = training_client.get_tags(custom_vision_project.id)

    # Create a list of images with tagged regions
    tagged_images_with_regions = []

    # Get the images and tagged regions from the JSON file
    with open('tagged-images.json', 'r') as json_file:
        tagged_images = json.load(json_file)
        for image in tagged_images['files']:
            # Get the filename
            file = image['filename']
            # Get the tagged regions
            regions = []
            for tag in image['tags']:
                tag_name = tag['tag']
                # Look up the tag ID for this tag name
                tag_id = next(t for t in tags if t.name == tag_name).id
                # Add a region for this tag using the coordinates and dimensions in the JSON
                regions.append(Region(tag_id=tag_id, left=tag['left'],top=tag['top'],width=tag['width'],height=tag['height']))
            # Add the image and its regions to the list
            with open(os.path.join(folder,file), mode="rb") as image_data:
                tagged_images_with_regions.append(ImageFileCreateEntry(name=file, contents=image_data.read(), regions=regions))

    # Upload the list of images as a batch
    upload_result = training_client.create_images_from_files(custom_vision_project.id, ImageFileCreateBatch(images=tagged_images_with_regions))
    # Check for failure
    if not upload_result.is_batch_successful:
        print("Image batch upload failed.")
        for image in upload_result.images:
            print("Image status: ", image.status)
    else:
        print("Images uploaded.")

if __name__ == "__main__":
    main()
```

train image json

```json
{
  "files": [
    {
      "filename": "image11.jpg",
      "tags": [
        {
          "tag": "orange",
          "left": 0.501782656,
          "top": 0.141307935,
          "width": 0.30014348,
          "height": 0.421263933
        },
        {
          "tag": "banana",
          "left": 0.117563143,
          "top": 0.269699484,
          "width": 0.4181828,
          "height": 0.629577756
        }
      ]
    },
    {
      "filename": "image12.jpg",
      "tags": [
        {
          "tag": "banana",
          "left": 0.0266054422,
          "top": 0.429971635,
          "width": 0.9334502,
          "height": 0.5663317
        },
        {
          "tag": "apple",
          "left": 0.594586432,
          "top": 0.139771029,
          "width": 0.2337932,
          "height": 0.313067973
        },
        {
          "tag": "orange",
          "left": 0.24538058,
          "top": 0.06600542,
          "width": 0.230479121,
          "height": 0.3283311
        }
      ]
    },
    {
      "filename": "image13.jpg",
      "tags": [
        {
          "tag": "orange",
          "left": 0.508894742,
          "top": 0.155026585,
          "width": 0.370887518,
          "height": 0.512516
        },
        {
          "tag": "banana",
          "left": 0.08663659,
          "top": 0.253976226,
          "width": 0.382285058,
          "height": 0.584964633
        }
      ]
    },
    {
      "filename": "image14.jpg",
      "tags": [
        {
          "tag": "apple",
          "left": 0.6080398,
          "top": 0.222880378,
          "width": 0.3454436,
          "height": 0.498601437
        },
        {
          "tag": "banana",
          "left": 0.08858037,
          "top": 0.2583913,
          "width": 0.394662261,
          "height": 0.6532483
        }
      ]
    },
    {
      "filename": "image15.jpg",
      "tags": [
        {
          "tag": "orange",
          "left": 0.124889567,
          "top": 0.160744965,
          "width": 0.365462124,
          "height": 0.503556669
        },
        {
          "tag": "banana",
          "left": 0.530725956,
          "top": 0.261967421,
          "width": 0.380674481,
          "height": 0.5697762
        }
      ]
    },
    {
      "filename": "image16.jpg",
      "tags": [
        {
          "tag": "banana",
          "left": 0.24473004,
          "top": 0.316017568,
          "width": 0.621397436,
          "height": 0.62547636
        },
        {
          "tag": "apple",
          "left": 0.2669289,
          "top": 0.1570937,
          "width": 0.2849568,
          "height": 0.373458445
        }
      ]
    },
    {
      "filename": "image17.jpg",
      "tags": [
        {
          "tag": "banana",
          "left": 0.137872428,
          "top": 0.3037218,
          "width": 0.6171047,
          "height": 0.6428385
        },
        {
          "tag": "apple",
          "left": 0.446089834,
          "top": 0.158026949,
          "width": 0.2905319,
          "height": 0.368484139
        }
      ]
    },
    {
      "filename": "image18.jpg",
      "tags": [
        {
          "tag": "banana",
          "left": 0.345145166,
          "top": 0.315790027,
          "width": 0.389697134,
          "height": 0.5641991
        },
        {
          "tag": "orange",
          "left": 0.6284472,
          "top": 0.160571277,
          "width": 0.25890553,
          "height": 0.321568727
        },
        {
          "tag": "orange",
          "left": 0.0472412556,
          "top": 0.317386866,
          "width": 0.344220281,
          "height": 0.451182485
        }
      ]
    },
    {
      "filename": "image19.jpg",
      "tags": [
        {
          "tag": "orange",
          "left": 0.190300852,
          "top": 0.04908291,
          "width": 0.6819816,
          "height": 0.89233005
        }
      ]
    },
    {
      "filename": "image20.jpg",
      "tags": [
        {
          "tag": "orange",
          "left": 0.296974,
          "top": 0.11914885,
          "width": 0.467207551,
          "height": 0.6827575
        }
      ]
    },
    {
      "filename": "image21.jpg",
      "tags": [
        {
          "tag": "orange",
          "left": 0.235896885,
          "top": 0.144391567,
          "width": 0.5458362,
          "height": 0.739897847
        }
      ]
    },
    {
      "filename": "image22.jpg",
      "tags": [
        {
          "tag": "orange",
          "left": 0.242359161,
          "top": 0.039894,
          "width": 0.632171631,
          "height": 0.903954148
        }
      ]
    },
    {
      "filename": "image23.jpg",
      "tags": [
        {
          "tag": "orange",
          "left": 0.242662221,
          "top": 0.06341483,
          "width": 0.670523345,
          "height": 0.7936373
        }
      ]
    },
    {
      "filename": "image24.jpg",
      "tags": [
        {
          "tag": "banana",
          "left": 0.06202866,
          "top": 0.319153845,
          "width": 0.9132734,
          "height": 0.640570164
        }
      ]
    },
    {
      "filename": "image25.jpg",
      "tags": [
        {
          "tag": "banana",
          "left": 0.234958112,
          "top": 0.165271968,
          "width": 0.51941216,
          "height": 0.77990067
        }
      ]
    },
    {
      "filename": "image26.jpg",
      "tags": [
        {
          "tag": "banana",
          "left": 0.123737864,
          "top": 0.311502129,
          "width": 0.6994619,
          "height": 0.6375427
        }
      ]
    },
    {
      "filename": "image27.jpg",
      "tags": [
        {
          "tag": "banana",
          "left": 0.147404462,
          "top": 0.332391232,
          "width": 0.708104849,
          "height": 0.41904977
        }
      ]
    },
    {
      "filename": "image28.jpg",
      "tags": [
        {
          "tag": "banana",
          "left": 0.294261217,
          "top": 0.262935251,
          "width": 0.476716518,
          "height": 0.7041446
        }
      ]
    },
    {
      "filename": "image29.jpg",
      "tags": [
        {
          "tag": "apple",
          "left": 0.152405351,
          "top": 0.105940014,
          "width": 0.598258257,
          "height": 0.8126528
        }
      ]
    },
    {
      "filename": "image30.jpg",
      "tags": [
        {
          "tag": "apple",
          "left": 0.255153179,
          "top": 0.1485295,
          "width": 0.528649,
          "height": 0.7251674
        }
      ]
    },
    {
      "filename": "image31.jpg",
      "tags": [
        {
          "tag": "apple",
          "left": 0.227940559,
          "top": 0.146328539,
          "width": 0.561518431,
          "height": 0.767682433
        }
      ]
    },
    {
      "filename": "image32.jpg",
      "tags": [
        {
          "tag": "apple",
          "left": 0.18220368,
          "top": 0.0870502,
          "width": 0.602320552,
          "height": 0.7840438
        }
      ]
    },
    {
      "filename": "image33.jpg",
      "tags": [
        {
          "tag": "apple",
          "left": 0.2639115,
          "top": 0.153765231,
          "width": 0.55621016,
          "height": 0.7570554
        }
      ]
    }
  ]
}
```

#### face:

##### computer vision:

```dotenv
AI_SERVICE_ENDPOINT=your_ai_services_endpoint
AI_SERVICE_KEY=your_ai_services_key
```

```python
from dotenv import load_dotenv
import os
from PIL import Image, ImageDraw
import sys
from matplotlib import pyplot as plt
import numpy as np

# import namespaces



def main():
    global cv_client

    try:
        # Get Configuration Settings
        load_dotenv()
        ai_endpoint = os.getenv('AI_SERVICE_ENDPOINT')
        ai_key = os.getenv('AI_SERVICE_KEY')

        # Get image
        image_file = 'images/people.jpg'
        if len(sys.argv) > 1:
            image_file = sys.argv[1]

        with open(image_file, "rb") as f:
            image_data = f.read()

        # Authenticate Azure AI Vision client


        # Analyze image
        AnalyzeImage(image_file, image_data, cv_client)

    except Exception as ex:
        print(ex)


def AnalyzeImage(filename, image_data, cv_client):
    print('
Analyzing ', filename)

    # Get result with specified features to be retrieved (PEOPLE)


    # Identify people in the image
    if result.people is not None:
        print("
People in image:")

        # Prepare image for drawing
        image = Image.open(filename)
        fig = plt.figure(figsize=(image.width/100, image.height/100))
        plt.axis('off')
        draw = ImageDraw.Draw(image)
        color = 'cyan'

        # Draw bounding box around detected people


        # Save annotated image
        plt.imshow(image)
        plt.tight_layout(pad=0)
        outputfile = 'people.jpg'
        fig.savefig(outputfile)
        print('  Results saved in', outputfile)

if __name__ == "__main__":
    main()
```

##### face api:

```python
from dotenv import load_dotenv
import os
from PIL import Image, ImageDraw
from matplotlib import pyplot as plt

# Import namespaces


def main():

    global face_client

    try:
        # Get Configuration Settings
        load_dotenv()
        cog_endpoint = os.getenv('AI_SERVICE_ENDPOINT')
        cog_key = os.getenv('AI_SERVICE_KEY')

        # Authenticate Face client


        # Menu for face functions
        print('1: Detect faces
Any other key to quit')
        command = input('Enter a number:')
        if command == '1':
            DetectFaces(os.path.join('images','people.jpg'))

    except Exception as ex:
        print(ex)

def DetectFaces(image_file):
    print('Detecting faces in', image_file)

    # Specify facial features to be retrieved


    # Get faces


if __name__ == "__main__":
    main()
```

```dotenv
AI_SERVICE_ENDPOINT=your_ai_services_endpoint
AI_SERVICE_KEY=your_ai_services_key
```

#### ocr:

```python
from dotenv import load_dotenv
import os
import time
from PIL import Image, ImageDraw
from matplotlib import pyplot as plt

# Import namespaces


def main():

    global cv_client

    try:
        # Get Configuration Settings
        load_dotenv()
        ai_endpoint = os.getenv('AI_SERVICE_ENDPOINT')
        ai_key = os.getenv('AI_SERVICE_KEY')

        # Authenticate Azure AI Vision client


        # Menu for text reading functions
        print('
1: Use Read API for image (Lincoln.jpg)
2: Read handwriting (Note.jpg)
Any other key to quit
')
        command = input('Enter a number:')
        if command == '1':
            image_file = os.path.join('images','Lincoln.jpg')
            GetTextRead(image_file)
        elif command =='2':
            image_file = os.path.join('images','Note.jpg')
            GetTextRead(image_file)


    except Exception as ex:
        print(ex)

def GetTextRead(image_file):
    print('
')

    # Open image file
    with open(image_file, "rb") as f:
            image_data = f.read()

    # Use Analyze image function to read text in image





if __name__ == "__main__":
    main()

```

```dotenv
AI_SERVICE_ENDPOINT=your_ai_services_endpoint
AI_SERVICE_KEY=your_ai_services_key
```

#### video indexer:

```powershell
$account_id="YOUR_ACCOUNT_ID"
$api_key="YOUR_API_KEY"
$location="trial"

# Call the AccessToken method with the API key in the header to get an access token
$token = Invoke-RestMethod -Method "Get" -Uri "https://api.videoindexer.ai/auth/$location/Accounts/$account_id/AccessToken" -Headers @{'Ocp-Apim-Subscription-Key' = $api_key}

# Use the access token to make an authenticated call to the Videos method to get a list of videos in the account
Invoke-RestMethod -Method "Get" -Uri "https://api.videoindexer.ai/$location/Accounts/$account_id/Videos?accessToken=$token" | ConvertTo-Json -Depth 6

```

```html
<html>
  <header>
    <title>Analyze Video</title>
    <script src="https://breakdown.blob.core.windows.net/public/vb.widgets.mediator.js"></script>
  </header>
  <body>
    <h1>Video Analysis</h1>
    <table>
      <tr>
        <td style="vertical-align:top;">
          <!--Player widget goes here -->
        </td>
        <td style="vertical-align:top;">
          <!-- Insights widget goes here -->
        </td>
      </tr>
    </table>
  </body>
</html>
```

#### custom vision image classification:

##### test-images:

```python
from azure.cognitiveservices.vision.customvision.prediction import CustomVisionPredictionClient
from msrest.authentication import ApiKeyCredentials
import os

def main():
    from dotenv import load_dotenv

    try:
        # Get Configuration Settings
        load_dotenv()
        prediction_endpoint = os.getenv('PredictionEndpoint')
        prediction_key = os.getenv('PredictionKey')
        project_id = os.getenv('ProjectID')
        model_name = os.getenv('ModelName')

        # Authenticate a client for the training API
        credentials = ApiKeyCredentials(in_headers={"Prediction-key": prediction_key})
        prediction_client = CustomVisionPredictionClient(endpoint=prediction_endpoint, credentials=credentials)

        # Classify test images
        for image in os.listdir('test-images'):
            image_data = open(os.path.join('test-images',image), "rb").read()
            results = prediction_client.classify_image(project_id, model_name, image_data)

            # Loop over each label prediction and print any with probability > 50%
            for prediction in results.predictions:
                if prediction.probability > 0.5:
                    print(image, ': {} ({:.0%})'.format(prediction.tag_name, prediction.probability))
    except Exception as ex:
        print(ex)

if __name__ == "__main__":
    main()


```

```dotenv
PredictionEndpoint=YOUR_PREDICTION_ENDPOINT
PredictionKey=YOUR_PREDICTION_KEY
ProjectID=YOUR_PROJECT_ID
ModelName=fruit-classifier
```

##### train-classifier:

```dotenv
TrainingEndpoint=YOUR_TRAINING_ENDPOINT
TrainingKey=YOUR_TRAINING_KEY
ProjectID=YOUR_PROJECT_ID
```

```python
from azure.cognitiveservices.vision.customvision.training import CustomVisionTrainingClient
from azure.cognitiveservices.vision.customvision.training.models import ImageFileCreateBatch, ImageFileCreateEntry, Region
from msrest.authentication import ApiKeyCredentials
import time
import os

def main():
    from dotenv import load_dotenv
    global training_client
    global custom_vision_project

    try:
        # Get Configuration Settings
        load_dotenv()
        training_endpoint = os.getenv('TrainingEndpoint')
        training_key = os.getenv('TrainingKey')
        project_id = os.getenv('ProjectID')

        # Authenticate a client for the training API
        credentials = ApiKeyCredentials(in_headers={"Training-key": training_key})
        training_client = CustomVisionTrainingClient(training_endpoint, credentials)

        # Get the Custom Vision project
        custom_vision_project = training_client.get_project(project_id)

        # Upload and tag images
        Upload_Images('more-training-images')

        # Train the model
        Train_Model()

    except Exception as ex:
        print(ex)

def Upload_Images(folder):
    print("Uploading images...")
    tags = training_client.get_tags(custom_vision_project.id)
    for tag in tags:
        print(tag.name)
        for image in os.listdir(os.path.join(folder,tag.name)):
            image_data = open(os.path.join(folder,tag.name,image), "rb").read()
            training_client.create_images_from_data(custom_vision_project.id, image_data, [tag.id])

def Train_Model():
    print("Training ...")
    iteration = training_client.train_project(custom_vision_project.id)
    while (iteration.status != "Completed"):
        iteration = training_client.get_iteration(custom_vision_project.id, iteration.id)
        print (iteration.status, '...')
        time.sleep(5)
    print ("Model trained!")


if __name__ == "__main__":
    main()

```


