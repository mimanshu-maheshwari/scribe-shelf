## Lab 4 (Classify images with a Azure AI Vision custom model):

#### image classification:

We also need a storage account to store the training images.

- In Azure portal, search for and select Storage accounts, and create a new storage account with the following settings:

  - Subscription: Your Azure subscription
  - Resource Group: Choose the same resource group you created your Azure AI Service resource in
  - Storage Account Name: customclassifySUFFIX
  - note: replace the SUFFIX token with your initials or another value to ensure the resource name is globally unique.
  - Region: Choose the same region you used for your Azure AI Service resource
  - Primary service: Azure Blob Storage or Azure Data Lake Storage Gen 2
  - Primary workload: Other
  - Performance: Standard
  - Redundancy: Locally-redundant storage (LRS)

- replace storage_account account in json file using this script

```powershell
$storageAcct = '<storageAccount>'
(Get-Content training-images/training_labels.json) -replace '<storageAccount>', $storageAcct | Out-File training-images/training_labels.json
```

- training_lables.json

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

Subscription: Your Azure subscription
Resource group: Choose or create a resource group (if you are using a restricted subscription, you may not have permission to create a new resource group - use the one provided)
Region: Choose from East US, West Europe, West US 2*
Name: Enter a unique name
Pricing tier: Standard S0
*Azure AI Vision 4.0 custom model tags are currently only available in these regions.

Select the required checkboxes and create the resource.

We also need a storage account to store the training images.

In Azure portal, search for and select Storage accounts, and create a new storage account with the following settings:

Subscription: Your Azure subscription
Resource Group: Choose the same resource group you created your Azure AI Service resource in
Storage Account Name: customclassifySUFFIX
note: replace the SUFFIX token with your initials or another value to ensure the resource name is globally unique.
Region: Choose the same region you used for your Azure AI Service resource
Primary service: Azure Blob Storage or Azure Data Lake Storage Gen 2
Primary workload: Other
Performance: Standard
Redundancy: Locally-redundant storage (LRS)
While your storage account is being created, go to Visual studio code, and expand the Labfiles/02-image-classification folder.

In that folder, select replace.ps1 and review the code. You'll see that it replaces the name of your storage account for the placeholder in a JSON file (the COCO file) we use in a later step. Replace the placeholder in the first line only of the file with the name of your storage account. Save the file.

Right-click on the 02-image-classification folder and open an Integrated Terminal. Run the following command.

Your storage account should be complete. Go to your storage account.

Enable public access on the storage account. In the left pane, navigate to Configuration in the Settings group, and enable Allow Blob anonymous access. Select Save

In the left pane, in Data storage, select Containers and create a new container named fruit, and set Anonymous access level to Container (anonymous read access for containers and blobs).

Note: If the Anonymous access level is disabled, refresh the browser page.

Navigate to fruit, select Upload, and upload the images (and the one JSON file) in Labfiles/02-image-classification/training-images to that container.

Create a custom model training project
Next, you will create a new training project for custom image classification in Vision Studio.

In the web browser, navigate to https://portal.vision.cognitive.azure.com/ and sign in with the Microsoft account where you created your Azure AI resource.
Select the Customize models with images tile (can be found in the Image analysis tab if it isn't showing in your default view).
Select the Azure AI Services account you created.
In your project, select Add new dataset on the top. Configure with the following settings:
Dataset name: training_images
Model type: Image classification
Select Azure blob storage container: Select Select Container
Subscription: Your Azure subscription
Storage account: The storage account you created
Blob container: fruit
Select the box to "Allow Vision Studio to read and write to your blob storage"
Select the training_images dataset.
At this point in project creation, you would usually select Create Azure ML Data Labeling Project and label your images, which generates a COCO file. You are encouraged to try this if you have time, but for the purposes of this lab we've already labeled the images for you and supplied the resulting COCO file.

Select Add COCO file
In the dropdown, select Import COCO file from a Blob Container
Since you have already connected your container named fruit, Vision Studio searches that for a COCO file. Select training_labels.json from the dropdown, and add the COCO file.
Navigate to Custom models on the left, and select Train a new model. Use the following settings:
Name of model: classifyfruit
Model type: Image classification
Choose training dataset: training_images
Leave the rest as default, and select Train model
Training can take some time - default budget is up to an hour, however for this small dataset it is usually much quicker than that. Select the Refresh button every couple minutes until the status of the job is Succeeded. Select the model.

Here you can view the performance of the training job. Review the precision and accuracy of the trained model.

Test your custom model
Your model has been trained and is ready to test.

On the top of the page for your custom model, select Try it out.
Select the `classifyfruit` model from the dropdown specifying the model you want to use, and browse to the 02-image-classification\test-images folder.
Select each image and view the results. Select the JSON tab in the results box to examine the full JSON response.


