## Lab 11(Use your own data with Azure OpenAI):
### Provision Azure resources
To complete this exercise, you'll need:

An Azure OpenAI resource.
An Azure AI Search resource.
An Azure Storage Account resource.
Sign into the Azure portal at https://portal.azure.com.

Create an Azure OpenAI resource with the following settings:

Subscription: Select an Azure subscription that has been approved for access to the Azure OpenAI service
Resource group: Choose or create a resource group
Region: Make a random choice from any of the following regions*
Australia East
Canada East
East US
East US 2
France Central
Japan East
North Central US
Sweden Central
Switzerland North
UK South
Name: A unique name of your choice
Pricing tier: Standard S0
* Azure OpenAI resources are constrained by regional quotas. The listed regions include default quota for the model type(s) used in this exercise. Randomly choosing a region reduces the risk of a single region reaching its quota limit in scenarios where you are sharing a subscription with other users. In the event of a quota limit being reached later in the exercise, there's a possibility you may need to create another resource in a different region.

While the Azure OpenAI resource is being provisioned, create an Azure AI Search resource with the following settings:

Subscription: The subscription in which you provisioned your Azure OpenAI resource
Resource group: The resource group in which you provisioned your Azure OpenAI resource
Service name: A unique name of your choice
Location: The region in which you provisioned your Azure OpenAI resource
Pricing tier: Basic
While the Azure AI Search resource is being provisioned, create a Storage account resource with the following settings:

Subscription: The subscription in which you provisioned your Azure OpenAI resource
Resource group: The resource group in which you provisioned your Azure OpenAI resource
Storage account name: A unique name of your choice
Region: The region in which you provisioned your Azure OpenAI resource
Performance: Standard
Redundancy: Locally redundant storage (LRS)
After all three of the resources have been successfully deployed in your Azure subscription, review them in the Azure portal and gather the following information (which you'll need later in the exercise):

The endpoint and a key from the Azure OpenAI resource you created (available on the Keys and Endpoint page for your Azure OpenAI resource in the Azure portal)
The endpoint for your Azure AI Search service (the Url value on the overview page for your Azure AI Search resource in the Azure portal).
A primary admin key for your Azure AI Search resource (available in the Keys page for your Azure AI Search resource in the Azure portal).

### Upload your data
You're going to ground the prompts you use with a generative AI model by using your own data. In this exercise, the data consists of a collection of travel brochures from the fictional Margies Travel company.

In a new browser tab, download an archive of brochure data from [ms own-data-brochures](https://aka.ms/own-data-brochures). Extract the brochures to a folder on your PC.
In the Azure portal, navigate to your storage account and view the Storage browser page.
Select Blob containers and then add a new container named margies-travel.
Select the margies-travel container, and then upload the .pdf brochures you extracted previously to the root folder of the blob container.

### Deploy AI models
You're going to use two AI models in this exercise:

A text embedding model to vectorize the text in the brochures so it can be indexed efficiently for use in grounding prompts.
A GPT model that you application can use to generate responses to prompts that are grounded in your data.
To deploy these models, you'll use AI Studio.

In the Azure portal, navigate to your Azure OpenAI resource. Then use the link to open your resource in Azure AI Studio..

In Azure AI Studio, on the Deployments page, view your existing model deployments. Then create a new base model deployment of the text-embedding-ada-002 model with the following settings:

Deployment name: text-embedding-ada-002
Model: text-embedding-ada-002
Model version: The default version
Deployment type: Standard
Tokens per minute rate limit: 5K*
Content filter: Default
Enable dynamic quota: Enabled
After the text embedding model has been deployed, return to the Deployments page and create a new deployment of the gpt-35-turbo-16k model with the following settings:

Deployment name: gpt-35-turbo-16k
Model: gpt-35-turbo-16k (if the 16k model isn't available, choose gpt-35-turbo)
Model version: The default version
Deployment type: Standard
Tokens per minute rate limit: 5K*
Content filter: Default
Enable dynamic quota: Enabled

### Create an index
To make it easy to use your own data in a prompt, you'll index it using Azure AI Search. You'll use the text embedding mdoel you deployed previously during the indexing process to vectorize the text data (which results in each text token in the index being represented by numeric vectors - making it compatible with the way a generative AI model represents text)

In the Azure portal, navigate to your Azure AI Search resource.
On the Overview page, select Import and vectorize data.
In the Setup your data connection page, select Azure Blob Storage and configure the data source with the following settings:
Subscription: The Azure subscription in which you provisioned your storage account.
Blob storage account: The storage account you created previously.
Blob container: margies-travel
Blob folder: Leave blank
Enable deletion tracking: Unselected
Authenticate using managed identity: Unselected
On the Vectorize your text page, select the following settings:
Kind: Azure OpenAI
Subscription: The Azure subscription in which you provisioned your Azure OpenAI service.
Azure OpenAI Service: Your Azure OpenAI Service resource
Model deployment: text-embedding-ada-002
Authentication type: API key
I acknowledge that connecting to an Azure OpenAI service will incur additional costs to my account: Selected
On the next page, do not select the option to vectorize images or extract data with AI skills.
On the next page, enable semantic ranking and schedule the indexer to run once.
On the final page, set the Objects name prefix to margies-index and then create the index.

https://github.com/MicrosoftLearning/mslearn-openai

```bash []
pip install openai==1.13.3
```
```dotenv []
AZURE_OAI_ENDPOINT="https://azure-ai-demo-open-ai-mm-own-data.openai.azure.com/"
AZURE_OAI_KEY="DvRaGBhibIe5JxHoCA5dngHy4zTHd2u9n2iHusuMsiYCiMg9ErESJQQJ99AKACYeBjFXJ3w3AAABACOGZLpx"
AZURE_OAI_DEPLOYMENT="gpt-35-turbo-16k"
AZURE_SEARCH_ENDPOINT="https://azure-ai-search-dmeo-mm-1.search.windows.net"
AZURE_SEARCH_KEY="ewm0NEn3PdXaSfVlFaZVMubcIICtSMmuAhgK0dqqUHAzSeBhSLN2"
AZURE_SEARCH_INDEX="margies-index"
```
```python []
import os
import json
from dotenv import load_dotenv

# Add OpenAI import
from openai import AzureOpenAI

def main(): 
        
    try:
        # Flag to show citations
        show_citations = True

        # Get configuration settings 
        load_dotenv()
        azure_oai_endpoint = os.getenv("AZURE_OAI_ENDPOINT")
        azure_oai_key = os.getenv("AZURE_OAI_KEY")
        azure_oai_deployment = os.getenv("AZURE_OAI_DEPLOYMENT")
        azure_search_endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
        azure_search_key = os.getenv("AZURE_SEARCH_KEY")
        azure_search_index = os.getenv("AZURE_SEARCH_INDEX")
        
        # Initialize the Azure OpenAI client
        client = AzureOpenAI(
            base_url=f"{azure_oai_endpoint}/openai/deployments/{azure_oai_deployment}/extensions",
            api_key=azure_oai_key,
            api_version="2023-09-01-preview")

        # Get the prompt
        text = input('
Enter a question:
')

        # Configure your data source
        extension_config = dict(dataSources = [  
                { 
                    "type": "AzureCognitiveSearch", 
                    "parameters": { 
                        "endpoint":azure_search_endpoint, 
                        "key": azure_search_key, 
                        "indexName": azure_search_index,
                    }
                }]
            )


        # Send request to Azure OpenAI model
        print("...Sending the following request to Azure OpenAI endpoint...")
        print("Request: " + text + "
")

        response = client.chat.completions.create(
            model = azure_oai_deployment,
            temperature = 0.5,
            max_tokens = 1000,
            messages = [
                {"role": "system", "content": "You are a helpful travel agent"},
                {"role": "user", "content": text}
            ],
            extra_body = extension_config
        )

        # Print response
        print("Response: " + response.choices[0].message.content + "
")

        if (show_citations):
            # Print citations
            print("Citations:")
            citations = response.choices[0].message.context["messages"][0]["content"]
            citation_json = json.loads(citations)
            for c in citation_json["citations"]:
                print("  Title: " + str(c['title']) + "
    URL: " + str(c['url']))


        
    except Exception as ex:
        print(ex)


if __name__ == '__main__': 
    main()
```










