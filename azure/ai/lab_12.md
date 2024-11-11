## Lab 12(Create a Custom Skill for Azure AI Search):
https://github.com/MicrosoftLearning/mslearn-knowledge-mining

In a web browser, open the Azure portal at https://portal.azure.com, and sign in using the Microsoft account associated with your Azure subscription.

In the top search bar, search for Azure AI services, select Azure AI services multi-service account, and create an Azure AI services multi-service account resource with the following settings:

Subscription: Your Azure subscription
Resource group: Choose or create a resource group (if you are using a restricted subscription, you may not have permission to create a new resource group - use the one provided)
Region: Choose from available regions geographically close to you
Name: Enter a unique name
Pricing tier: Standard S0
Once deployed, go to the resource and on the Overview page, note the Subscription ID and Location. You will need these values, along with the name of the resource group in subsequent steps.

In Visual Studio Code, expand the Labfiles/02-search-skill folder and select setup.cmd. You will use this batch script to run the Azure command line interface (CLI) commands required to create the Azure resources you need.

Right-click the the 02-search-skill folder and select Open in Integrated Terminal.

In the terminal pane, enter the following command to establish an authenticated connection to your Azure subscription.

```powershell
az login --output none
```
When prompted, select or sign into your Azure subscription. Then return to Visual Studio Code and wait for the sign-in process to complete.

Run the following command to list Azure locations.

```powershell
az account list-locations -o table
```
In the output, find the Name value that corresponds with the location of your resource group (for example, for East US the corresponding name is eastus).

In the setup.cmd script, modify the subscription_id, resource_group, and location variable declarations with the appropriate values for your subscription ID, resource group name, and location name. Then save your changes.

In the terminal for the 02-search-skill folder, enter the following command to run the script:

powershell
./setup
Note: If the script fails, ensure you saved it with the correct variable names and try again.

When the script completes, review the output it displays and note the following information about your Azure resources (you will need these values later):

Storage account name
Storage connection string
Search service endpoint
Search service admin key
Search service query key
In the Azure portal, refresh the resource group and verify that it contains the Azure Storage account, Azure AI Services resource, and Azure AI Search resource.
- input
```cmd 
@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

rem Set values for your subscription and resource group
set subscription_id="f8f10a38-d7ef-46c9-8f50-7ab13e685b13"
set resource_group="ResourceGroup1"
set location="eastus"

rem Get random numbers to create unique resource names
set unique_id=!random!!random!

echo Creating storage...
call az storage account create --name ai102str!unique_id! --subscription !subscription_id! --resource-group !resource_group! --location !location! --sku Standard_LRS --encryption-services blob --default-action Allow --allow-blob-public-access true --only-show-errors --output none

echo Uploading files...
rem Hack to get storage key
for /f "tokens=*" %%a in ( 
'az storage account keys list --subscription !subscription_id! --resource-group !resource_group! --account-name ai102str!unique_id! --query "[?keyName=='key1'].{keyName:keyName, permissions:permissions, value:value}"' 
) do ( 
set key_json=!key_json!%%a 
) 
set key_string=!key_json:[ { "keyName": "key1", "permissions": "Full", "value": "=!
set AZURE_STORAGE_KEY=!key_string:" } ]=!
call az storage container create --account-name ai102str!unique_id! --name margies --public-access blob --auth-mode key --account-key %AZURE_STORAGE_KEY% --output none
call az storage blob upload-batch -d margies -s data --account-name ai102str!unique_id! --auth-mode key --account-key %AZURE_STORAGE_KEY%  --output none

echo Creating search service...
echo (If this gets stuck at '- Running ..' for more than a couple minutes, press CTRL+C then select N)
call az search service create --name ai102srch!unique_id! --subscription !subscription_id! --resource-group !resource_group! --location !location! --sku basic --output none

echo -------------------------------------
echo Storage account: ai102str!unique_id!
call az storage account show-connection-string --subscription !subscription_id! --resource-group !resource_group! --name ai102str!unique_id!
echo ----
echo Search Service: ai102srch
echo  Url: https://ai102srch!unique_id!.search.windows.net
echo  Admin Keys:
call az search admin-key show --subscription !subscription_id! --resource-group !resource_group! --service-name ai102srch!unique_id!
echo  Query Keys:
call az search query-key list --subscription !subscription_id! --resource-group !resource_group! --service-name ai102srch!unique_id!
```
- output
```
Storage account: ai102str2888316906
{
  "connectionString": "DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=ai102str2888316906;AccountKey=oR83e9kywhbE5Jp93A7CPZmJyLR9ZAeu0lOe9YlLKJCxk1aUxRl2Lu3Z965gFaaP9W2agh0H98ib+AStZCM0wA==;BlobEndpoint=https://ai102str2888316906.blob.core.windows.net/;FileEndpoint=https://ai102str2888316906.file.core.windows.net/;QueueEndpoint=https://ai102str2888316906.queue.core.windows.net/;TableEndpoint=https://ai102str2888316906.table.core.windows.net/"
}
----
Search Service: ai102srch
 Url: https://ai102srch2888316906.search.windows.net
 Admin Keys:
{
  "primaryKey": "ZYzSJloH90JtjGYIj8RWxjom1Uj0KAcHFAhmfne2CAAzSeD2XLjj",
  "secondaryKey": "uGzjMq9EDljQXu3VLOzPBp1Auu4EShMNlnJSFmJMXWAzSeB5LUcS"
}
 Query Keys:
[
  {
    "key": "xkl1kRbCe3mN6PHXxYxs7vukfQ9hx1Kq3UM9x2gJV6AzSeDvxCBr",
    "name": null
  }
]
```

### Create a search solution
Now that you have the necessary Azure resources, you can create a search solution that consists of the following components:

A data source that references the documents in your Azure storage container.
A skillset that defines an enrichment pipeline of skills to extract AI-generated fields from the documents.
An index that defines a searchable set of document records.
An indexer that extracts the documents from the data source, applies the skillset, and populates the index.
In this exercise, you'll use the Azure AI Search REST interface to create these components by submitting JSON requests.

In Visual Studio Code, in the 02-search-skill folder, expand the create-search folder and select data_source.json. This file contains a JSON definition for a data source named margies-custom-data.

Replace the YOUR_CONNECTION_STRING placeholder with the connection string for your Azure storage account, which should resemble the following:

DefaultEndpointsProtocol=https;AccountName=ai102str123;AccountKey=12345abcdefg...==;EndpointSuffix=core.windows.net
You can find the connection string on the Access keys page for your storage account in the Azure portal.

Save and close the updated JSON file.

In the create-search folder, open skillset.json. This file contains a JSON definition for a skillset named margies-custom-skillset.

At the top of the skillset definition, in the cognitiveServices element, replace the YOUR_AI_SERVICES_KEY placeholder with either of the keys for your Azure AI Services resources.

You can find the keys on the Keys and Endpoint page for your Azure AI Services resource in the Azure portal.

Save and close the updated JSON file.

In the create-search folder, open index.json. This file contains a JSON definition for an index named margies-custom-index.

Review the JSON for the index, then close the file without making any changes.

In the create-search folder, open indexer.json. This file contains a JSON definition for an indexer named margies-custom-indexer.

Review the JSON for the indexer, then close the file without making any changes.

In the create-search folder, open create-search.cmd. This batch script uses the cURL utility to submit the JSON definitions to the REST interface for your Azure AI Search resource.

Replace the YOUR_SEARCH_URL and YOUR_ADMIN_KEY variable placeholders with the Url and one of the admin keys for your Azure AI Search resource.

You can find these values on the Overview and Keys pages for your Azure AI Search resource in the Azure portal.

Save the updated batch file.

Right-click the the create-search folder and select Open in Integrated Terminal.

In the terminal pane for the create-search folder, enter the following command run the batch script.

powershell
./create-search
When the script completes, in the Azure portal, on the page for your Azure AI Search resource, select the Indexers page and wait for the indexing process to complete.

You can select Refresh to track the progress of the indexing operation. It may take a minute or so to complete.

### Search the index
Now that you have an index, you can search it.

At the top of the blade for your Azure AI Search resource, select Search explorer.

In Search explorer, in the Query string box, enter the following query string, and then select Search.

search=London&$select=url,sentiment,keyphrases&$filter=metadata_author eq 'Reviewer' and sentiment eq 'positive'
This query retrieves the url, sentiment, and keyphrases for all documents that mention London authored by Reviewer that have a positive sentiment label (in other words, positive reviews that mention London)

### Create an Azure Function for a custom skill
The search solution includes a number of built-in AI skills that enrich the index with information from the documents, such as the sentiment scores and lists of key phrases seen in the previous task.

You can enhance the index further by creating custom skills. For example, it might be useful to identify the words that are used most frequently in each document, but no built-in skill offers this functionality.

To implement the word count functionality as a custom skill, you'll create an Azure Function in your preferred language.

Note: In this exercise, you'll create a simple Node.JS function using the code editing capabilities in the Azure portal. In a production solution, you would typically use a development environment such as Visual Studio Code to create a function app in your preferred language (for example C#, Python, Node.JS, or Java) and publish it to Azure as part of a DevOps process.

In the Azure Portal, on the Home page, create a new Function App resource with the following settings:

Hosting Plan: Consumption
Subscription: Your subscription
Resource Group: The same resource group as your Azure AI Search resource
Function App name: FunctionApp45606619
Runtime stack: Node.js
Version: 18 LTS
Region: The same region as your Azure AI Search resource
Operating system: Windows
Wait for deployment to complete, and then go to the deployed Function App resource.

On the Overview page select Create function at the bottom of the page to create a new function with the following settings:

Select a template
Template: HTTP Trigger
Template details:
Function name: wordcount
Authorization level: Function
Wait for the wordcount function to be created. Then in its page, select the Code + Test tab.

Replace the default function code with the following code:

``` javascript
module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    if (req.body && req.body.values) {

        vals = req.body.values;

        // Array of stop words to be ignored
        var stopwords = ['', 'i', 'me', 'my', 'myself', 'we', 'our', 'ours', 'ourselves', 'you', 
        "youre", "youve", "youll", "youd", 'your', 'yours', 'yourself', 
        'yourselves', 'he', 'him', 'his', 'himself', 'she', "shes", 'her', 
        'hers', 'herself', 'it', "its", 'itself', 'they', 'them', 
        'their', 'theirs', 'themselves', 'what', 'which', 'who', 'whom', 
        'this', 'that', "thatll", 'these', 'those', 'am', 'is', 'are', 'was',
        'were', 'be', 'been', 'being', 'have', 'has', 'had', 'having', 'do', 
        'does', 'did', 'doing', 'a', 'an', 'the', 'and', 'but', 'if', 'or', 
        'because', 'as', 'until', 'while', 'of', 'at', 'by', 'for', 'with', 
        'about', 'against', 'between', 'into', 'through', 'during', 'before', 
        'after', 'above', 'below', 'to', 'from', 'up', 'down', 'in', 'out', 
        'on', 'off', 'over', 'under', 'again', 'further', 'then', 'once', 'here', 
        'there', 'when', 'where', 'why', 'how', 'all', 'any', 'both', 'each', 
        'few', 'more', 'most', 'other', 'some', 'such', 'no', 'nor', 'not', 
        'only', 'own', 'same', 'so', 'than', 'too', 'very', 'can', 'will',
        'just', "dont", 'should', "shouldve", 'now', "arent", "couldnt", 
        "didnt", "doesnt", "hadnt", "hasnt", "havent", "isnt", "mightnt", "mustnt",
        "neednt", "shant", "shouldnt", "wasnt", "werent", "wont", "wouldnt"];

        res = {"values":[]};

        for (rec in vals)
        {
            // Get the record ID and text for this input
            resVal = {recordId:vals[rec].recordId, data:{}};
            txt = vals[rec].data.text;

            // remove punctuation and numerals
            txt = txt.replace(/[^ A-Za-z_]/g,"").toLowerCase();

            // Get an array of words
            words = txt.split(" ")

            // count instances of non-stopwords
            wordCounts = {}
            for(var i = 0; i < words.length; ++i) {
                word = words[i];
                if (stopwords.includes(word) == false )
                {
                    if (wordCounts[word])
                    {
                        wordCounts[word] ++;
                    }
                    else
                    {
                        wordCounts[word] = 1;
                    }
                }
            }

            // Convert wordcounts to an array
            var topWords = [];
            for (var word in wordCounts) {
                topWords.push([word, wordCounts[word]]);
            }

            // Sort in descending order of count
            topWords.sort(function(a, b) {
                return b[1] - a[1];
            });

            // Get the first ten words from the first array dimension
            resVal.data.text = topWords.slice(0,9)
              .map(function(value,index) { return value[0]; });

            res.values[rec] = resVal;
        };

        context.res = {
            body: JSON.stringify(res),
            headers: {
            'Content-Type': 'application/json'
        }

        };
    }
    else {
        context.res = {
            status: 400,
            body: {"errors":[{"message": "Invalid input"}]},
            headers: {
            'Content-Type': 'application/json'
        }

        };
    }
};
```
Save the function and then open the Test/Run pane.

In the Test/Run pane, replace the existing Body with the following JSON, which reflects the schema expected by an Azure AI Search skill in which records containing data for one or more documents are submitted for processing:

```json
{
    "values": [
        {
            "recordId": "a1",
            "data":
            {
            "text":  "Tiger, tiger burning bright in the darkness of the night.",
            "language": "en"
            }
        },
        {
            "recordId": "a2",
            "data":
            {
            "text":  "The rain in spain stays mainly in the plains! That's where you'll find the rain!",
            "language": "en"
            }
        }
    ]
}
```
Click Run and view the HTTP response content that is returned by your function. This reflects the schema expected by Azure AI Search when consuming a skill, in which a response for each document is returned. In this case, the response consists of up to 10 terms in each document in descending order of how frequently they appear:

```json
{
    "values": [
    {
        "recordId": "a1",
        "data": {
            "text": [
            "tiger",
            "burning",
            "bright",
            "darkness",
            "night"
            ]
        }
    },
    {
        "recordId": "a2",
        "data": {
            "text": [
                "rain",
                "spain",
                "stays",
                "mainly",
                "plains",
                "thats",
                "youll",
                "find"
            ]
        }
    }
    ]
}
```
Close the Test/Run pane and in the wordcount function blade, click Get function URL. Then copy the URL for the default key to the clipboard. You'll need this in the next procedure.



### Add the custom skill to the search solution
Now you need to include your function as a custom skill in the search solution skillset, and map the results it produces to a field in the index.

In Visual Studio Code, in the 02-search-skill/update-search folder, open the update-skillset.json file. This contains the JSON definition of a skillset.

Review the skillset definition. It includes the same skills as before, as well as a new WebApiSkill skill named get-top-words.

Edit the get-top-words skill definition to set the uri value to the URL for your Azure function (which you copied to the clipboard in the previous procedure), replacing YOUR-FUNCTION-APP-URL.

At the top of the skillset definition, in the cognitiveServices element, replace the YOUR_AI_SERVICES_KEY placeholder with either of the keys for your Azure AI Services resources.

You can find the keys on the Keys and Endpoint page for your Azure AI Services resource in the Azure portal.

Save and close the updated JSON file.

In the update-search folder, open update-index.json. This file contains the JSON definition for the margies-custom-index index, with an additional field named top_words at the bottom of the index definition.

Review the JSON for the index, then close the file without making any changes.

In the update-search folder, open update-indexer.json. This file contains a JSON definition for the margies-custom-indexer, with an additional mapping for the top_words field.

Review the JSON for the indexer, then close the file without making any changes.

In the update-search folder, open update-search.cmd. This batch script uses the cURL utility to submit the updated JSON definitions to the REST interface for your Azure AI Search resource.

Replace the YOUR_SEARCH_URL and YOUR_ADMIN_KEY variable placeholders with the Url and one of the admin keys for your Azure AI Search resource.

You can find these values on the Overview and Keys pages for your Azure AI Search resource in the Azure portal.

Save the updated batch file.

Right-click the the update-search folder and select Open in Integrated Terminal.

In the terminal pane for the update-search folder, enter the following command run the batch script.

powershell
./update-search
When the script completes, in the Azure portal, on the page for your Azure AI Search resource, select the Indexers page and wait for the indexing process to complete.

You can select Refresh to track the progress of the indexing operation. It may take a minute or so to complete.

### Search the index
Now that you have an index, you can search it.

At the top of the blade for your Azure AI Search resource, select Search explorer.

In Search explorer, change the view to JSON view, and then submit the following search query:

```json
{
  "search": "Las Vegas",
  "select": "url,top_words"
}
```
This query retrieves the url and top_words fields for all documents that mention Las Vegas.


