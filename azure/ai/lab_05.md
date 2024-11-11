## Lab 5(Analyze text):
[AI language Github](https://github.com/MicrosoftLearning/mslearn-ai-language)
Provision an Azure AI Language resource
If you don't already have one in your subscription, you'll need to provision an Azure AI Language service resource in your Azure subscription.

Open the Azure portal at https://portal.azure.com, and sign in using the Microsoft account associated with your Azure subscription.
Select Create a resource.
In the search field, search for Language service. Then, in the results, select Create under Language Service.
Select Continue to create your resource.
Provision the resource using the following settings:
Subscription: Your Azure subscription.
Resource group: Choose or create a resource group.
Region:Choose any available region
Name: Enter a unique name.
Pricing tier: Select F0 (free), or S (standard) if F is not available.
Responsible AI Notice: Agree.
Select Review + create, then select Create to provision the resource.
Wait for deployment to complete, and then go to the deployed resource.
View the Keys and Endpoint page in the Resource Management section. You will need the information on this page later in the exercise.


```console
pip install azure-ai-textanalytics==5.3.0
pip install python-dotenv
```

```dotenv
AI_SERVICE_ENDPOINT="https://azure-ai-language-service-mm-ttt.cognitiveservices.azure.com/"
AI_SERVICE_KEY="1yYrQqBzdromgZgrAN6f9A4ZF2cq22I6BbGXupWs9N7P4HQ2z8TdJQQJ99AKACYeBjFXJ3w3AAAaACOGgAmK"
```

```python
from dotenv import load_dotenv
import os

# Import namespaces
from azure.core.credentials import AzureKeyCredential
from azure.ai.textanalytics import TextAnalyticsClient

def main():
    try:
        # Get Configuration Settings
        load_dotenv()
        ai_endpoint = os.getenv('AI_SERVICE_ENDPOINT')
        ai_key = os.getenv('AI_SERVICE_KEY')

        # Create client using endpoint and key
        credential = AzureKeyCredential(ai_key)
        ai_client = TextAnalyticsClient(endpoint=ai_endpoint, credential=credential)


        # Analyze each text file in the reviews folder
        reviews_folder = 'reviews'
        for file_name in os.listdir(reviews_folder):
            # Read the file contents
            print('
-------------
' + file_name)
            text = open(os.path.join(reviews_folder, file_name), encoding='utf8').read()
            print('
' + text)

            # Get language
            detectedLanguage = ai_client.detect_language(documents=[text])[0]
            print('
Language: {}'.format(detectedLanguage.primary_language.name))


            # Get sentiment
            sentimentAnalysis = ai_client.analyze_sentiment(documents=[text])[0]
            print("
Sentiment: {}".format(sentimentAnalysis.sentiment))


            # Get key phrases
            phrases = ai_client.extract_key_phrases(documents=[text])[0].key_phrases
            if len(phrases) > 0:
                print("
Key Phrases:")
                for phrase in phrases:
                    print('\t{}'.format(phrase))


            # Get entities
            entities = ai_client.recognize_entities(documents=[text])[0].entities
            if len(entities) > 0:
                print("
Entities")
                for entity in entities:
                    print('\t{} ({})'.format(entity.text, entity.category))


            # Get linked entities
            entities = ai_client.recognize_linked_entities(documents=[text])[0].entities
            if len(entities) > 0:
                print("
Links")
                for linked_entity in entities:
                    print('\t{} ({})'.format(linked_entity.name, linked_entity.url))


    except Exception as ex:
        print(ex)


if __name__ == "__main__":
    main()
```


