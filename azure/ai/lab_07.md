## Lab 7 (Create a language understanding model with the Language service): 
Create a language understanding model with the Language service
NOTE The conversational language understanding feature of the Azure AI Language service is currently in preview, and subject to change. In some cases, model training may fail - if this happens, try again.

The Azure AI Language service enables you to define a conversational language understanding model that applications can use to interpret natural language input from users, predict the users intent (what they want to achieve), and identify any entities to which the intent should be applied.

For example, a conversational language model for a clock application might be expected to process input such as:

What is the time in London?

This kind of input is an example of an utterance (something a user might say or type), for which the desired intent is to get the time in a specific location (an entity); in this case, London.

NOTE The task of a conversational language model is to predict the user's intent and identify any entities to which the intent applies. It is not the job of a conversational language model to actually perform the actions required to satisfy the intent. For example, a clock application can use a conversational language model to discern that the user wants to know the time in London; but the client application itself must then implement the logic to determine the correct time and present it to the user.

Provision an Azure AI Language resource
If you don't already have one in your subscription, you'll need to provision an Azure AI Language service resource in your Azure subscription.

Open the Azure portal at https://portal.azure.com, and sign in using the Microsoft account associated with your Azure subscription.
In the search field at the top, search for Azure AI services. Then, in the results, select Create under Language Service.
Select Continue to create your resource.
Provision the resource using the following settings:
Subscription: Your Azure subscription.
Resource group: Choose or create a resource group.
Region: Choose from one of the following regions*
Australia East
Central India
China East 2
East US
East US 2
North Europe
South Central US
Switzerland North
UK South
West Europe
West US 2
West US 3
Name: Enter a unique name.
Pricing tier: Select F0 (free), or S (standard) if F is not available.
Responsible AI Notice: Agree.
Select Review + create, then select Create to provision the resource.
Wait for deployment to complete, and then go to the deployed resource.
View the Keys and Endpoint page. You will need the information on this page later in the exercise.
Create a conversational language understanding project
Now that you have created an authoring resource, you can use it to create a conversational language understanding project.

In a new browser tab, open the Azure AI Language Studio portal at https://language.cognitive.azure.com/ and sign in using the Microsoft account associated with your Azure subscription.

If prompted to choose a Language resource, select the following settings:

Azure Directory: The Azure directory containing your subscription.
Azure subscription: Your Azure subscription.
Resource type: Language.
Language resource: The Azure AI Language resource you created previously.
If you are not prompted to choose a language resource, it may be because you have multiple Language resources in your subscription; in which case:

On the bar at the top of the page, select the Settings (⚙) button.
On the Settings page, view the Resources tab.
Select the language resource you just created, and click Switch resource.
At the top of the page, click Language Studio to return to the Language Studio home page
At the top of the portal, in the Create new menu, select Conversational language understanding.

In the Create a project dialog box, on the Enter basic information page, enter the following details and then select Next:

Name: Clock
Utterances primary language: English
Enable multiple languages in project?: Unselected
Description: Natural language clock
On the Review and finish page, select Create.

Create intents
The first thing we'll do in the new project is to define some intents. The model will ultimately predict which of these intents a user is requesting when submitting a natural language utterance.

Tip: When working on your project, if some tips are displayed, read them and select Got it to dismiss them, or select Skip all.

On the Schema definition page, on the Intents tab, select ＋ Add to add a new intent named GetTime.
Verify that the GetTime intent is listed (along with the default None intent). Then add the following additional intents:
GetDay
GetDate
Label each intent with sample utterances
To help the model predict which intent a user is requesting, you must label each intent with some sample utterances.

In the pane on the left, select the Data Labeling page.
Tip: You can expand the pane with the >> icon to see the page names, and hide it again with the << icon.

Select the new GetTime intent and enter the utterance what is the time?. This adds the utterance as sample input for the intent.

Add the following additional utterances for the GetTime intent:

what's the time?
what time is it?
tell me the time
NOTE To add a new utterance, write the utterance in the textbox next to the intent and then press ENTER.

Select the GetDay intent and add the following utterances as example input for that intent:

what day is it?
what's the day?
what is the day today?
what day of the week is it?
Select the GetDate intent and add the following utterances for it:

what date is it?
what's the date?
what is the date today?
what's today's date?
After you've added utterances for each of your intents, select Save changes.

Train and test the model
Now that you've added some intents, let's train the language model and see if it can correctly predict them from user input.

In the pane on the left, select Training jobs. Then select + Start a training job.

On the Start a training job dialog, select the option to train a new model, name it Clock. Select Standard training mode and the default Data splitting options.

To begin the process of training your model, select Train.

When training is complete (which may take several minutes) the job Status will change to Training succeeded.

Select the Model performance page, and then select the Clock model. Review the overall and per-intent evaluation metrics (precision, recall, and F1 score) and the confusion matrix generated by the evaluation that was performed when training (note that due to the small number of sample utterances, not all intents may be included in the results).

NOTE To learn more about the evaluation metrics, refer to the documentation

Go to the Deploying a model page, then select Add deployment.

On the Add deployment dialog, select Create a new deployment name, and then enter production.

Select the Clock model in the Model field then select Deploy. The deployment may take some time.

When the model has been deployed, select the Testing deployments page, then select the production deployment in the Deployment name field.

Enter the following text in the empty textbox, and then select Run the test:

what's the time now?

Review the result that is returned, noting that it includes the predicted intent (which should be GetTime) and a confidence score that indicates the probability the model calculated for the predicted intent. The JSON tab shows the comparative confidence for each potential intent (the one with the highest confidence score is the predicted intent)

Clear the text box, and then run another test with the following text:

tell me the time

Again, review the predicted intent and confidence score.

Try the following text:

what's the day today?

Hopefully the model predicts the GetDay intent.

Add entities
So far you've defined some simple utterances that map to intents. Most real applications include more complex utterances from which specific data entities must be extracted to get more context for the intent.

Add a learned entity
The most common kind of entity is a learned entity, in which the model learns to identify entity values based on examples.

In Language Studio, return to the Schema definition page and then on the Entities tab, select ＋ Add to add a new entity.

In the Add an entity dialog box, enter the entity name Location and ensure that the Learned tab is selected. Then select Add entity.

After the Location entity has been created, return to the Data labeling page.

Select the GetTime intent and enter the following new example utterance:

what time is it in London?

When the utterance has been added, select the word London, and in the drop-down list that appears, select Location to indicate that "London" is an example of a location.

Add another example utterance for the GetTime intent:

Tell me the time in Paris?

When the utterance has been added, select the word Paris, and map it to the Location entity.

Add another example utterance for the GetTime intent:

what's the time in New York?

When the utterance has been added, select the words New York, and map them to the Location entity.

Select Save changes to save the new utterances.

Add a list entity
In some cases, valid values for an entity can be restricted to a list of specific terms and synonyms; which can help the app identify instances of the entity in utterances.

In Language Studio, return to the Schema definition page and then on the Entities tab, select ＋ Add to add a new entity.

In the Add an entity dialog box, enter the entity name Weekday and select the List entity tab. Then select Add entity.

On the page for the Weekday entity, in the Learned section, ensure Not required is selected. Then, in the List section, select ＋ Add new list. Then enter the following value and synonym and select Save:

List key	synonyms
Sunday	Sun
NOTE To enter the fields of the new list, insert the value Sunday in the text field, then click on the field where 'Type in value and press enter…' is displayed, enter the synonyms, and press ENTER.

Repeat the previous step to add the following list components:

Value	synonyms
Monday	Mon
Tuesday	Tue, Tues
Wednesday	Wed, Weds
Thursday	Thur, Thurs
Friday	Fri
Saturday	Sat
After adding and saving the list values, return to the Data labeling page.

Select the GetDate intent and enter the following new example utterance:

what date was it on Saturday?

When the utterance has been added, select the word Saturday, and in the drop-down list that appears, select Weekday.

Add another example utterance for the GetDate intent:

what date will it be on Friday?

When the utterance has been added, map Friday to the Weekday entity.

Add another example utterance for the GetDate intent:

what will the date be on Thurs?

When the utterance has been added, map Thurs to the Weekday entity.

select Save changes to save the new utterances.

Add a prebuilt entity
The Azure AI Language service provides a set of prebuilt entities that are commonly used in conversational applications.

In Language Studio, return to the Schema definition page and then on the Entities tab, select ＋ Add to add a new entity.

In the Add an entity dialog box, enter the entity name Date and select the Prebuilt entity tab. Then select Add entity.

On the page for the Date entity, in the Learned section, ensure Not required is selected. Then, in the Prebuilt section, select ＋ Add new prebuilt.

In the Select prebuilt list, select DateTime and then select Save.

After adding the prebuilt entity, return to the Data labeling page

Select the GetDay intent and enter the following new example utterance:

what day was 01/01/1901?

When the utterance has been added, select 01/01/1901, and in the drop-down list that appears, select Date.

Add another example utterance for the GetDay intent:

what day will it be on Dec 31st 2099?

When the utterance has been added, map Dec 31st 2099 to the Date entity.

Select Save changes to save the new utterances.

Retrain the model
Now that you've modified the schema, you need to retrain and retest the model.

On the Training jobs page, select Start a training job.

On the Start a training job dialog, select overwrite an existing model and specify the Clock model. Select Train to train the model. If prompted, confirm you want to overwrite the existing model.

When training is complete the job Status will update to Training succeeded.

Select the Model performance page and then select the Clock model. Review the evaluation metrics (precision, recall, and F1 score) and the confusion matrix generated by the evaluation that was performed when training (note that due to the small number of sample utterances, not all intents may be included in the results).

On the Deploying a model page, select Add deployment.

On the Add deployment dialog, select Override an existing deployment name, and then select production.

Select the Clock model in the Model field and then select Deploy to deploy it. This may take some time.

When the model is deployed, on the Testing deployments page, select the production deployment under the Deployment name field, and then test it with the following text:

- what's the time in Edinburgh?

Review the result that is returned, which should hopefully predict the GetTime intent and a Location entity with the text value "Edinburgh".

Try testing the following utterances:

- what time is it in Tokyo?
- what date is it on Friday?
- what's the date on Weds?
- what day was 01/01/2020?
- what day will Mar 7th 2030 be?

```bash
pip install azure-ai-language-conversations
```
- .env
```dotenv 
LS_CONVERSATIONS_ENDPOINT="https://azure-ai-language-mm-ret.cognitiveservices.azure.com/"
LS_CONVERSATIONS_KEY="7M6pb3ZJPrGRoGkkjqdjjVCsJCuWlszWgVOmHlw1XQHnKPOjIkvtJQQJ99AKACYeBjFXJ3w3AAAaACOGoZam"
```
- clock-client.py
```python 
from dotenv import load_dotenv
import os
import json
from datetime import datetime, timedelta, date, timezone
from dateutil.parser import parse as is_date

# Import namespaces
from azure.core.credentials import AzureKeyCredential
from azure.ai.language.conversations import ConversationAnalysisClient

def main():

    try:
        # Get Configuration Settings
        load_dotenv()
        ls_prediction_endpoint = os.getenv('LS_CONVERSATIONS_ENDPOINT')
        ls_prediction_key = os.getenv('LS_CONVERSATIONS_KEY')

        # Get user input (until they enter "quit")
        userText = ''
        while userText.lower() != 'quit':
            userText = input('
Enter some text ("quit" to stop)
')
            if userText.lower() != 'quit':

                # Create a client for the Language service model
                client = ConversationAnalysisClient(
                    ls_prediction_endpoint, AzureKeyCredential(ls_prediction_key))
                # Call the Language service model to get intent and entities
                cls_project = 'Clock'
                deployment_slot = 'production'

                with client:
                    query = userText
                    result = client.analyze_conversation(
                        task={
                            "kind": "Conversation",
                            "analysisInput": {
                                "conversationItem": {
                                    "participantId": "1",
                                    "id": "1",
                                    "modality": "text",
                                    "language": "en",
                                    "text": query
                                },
                                "isLoggingEnabled": False
                            },
                            "parameters": {
                                "projectName": cls_project,
                                "deploymentName": deployment_slot,
                                "verbose": True
                            }
                        }
                    )

                top_intent = result["result"]["prediction"]["topIntent"]
                entities = result["result"]["prediction"]["entities"]

                print("view top intent:")
                print("\ttop intent: {}".format(result["result"]["prediction"]["topIntent"]))
                print("\tcategory: {}".format(result["result"]["prediction"]["intents"][0]["category"]))
                print("\tconfidence score: {}
".format(result["result"]["prediction"]["intents"][0]["confidenceScore"]))

                print("view entities:")
                for entity in entities:
                    print("\tcategory: {}".format(entity["category"]))
                    print("\ttext: {}".format(entity["text"]))
                    print("\tconfidence score: {}".format(entity["confidenceScore"]))

                print("query: {}".format(result["result"]["query"]))

                # Apply the appropriate action
                if top_intent == 'GetTime':
                    location = 'local'
                    # Check for entities
                    if len(entities) > 0:
                        # Check for a location entity
                        for entity in entities:
                            if 'Location' == entity["category"]:
                                # ML entities are strings, get the first one
                                location = entity["text"]
                    # Get the time for the specified location
                    print(GetTime(location))

                elif top_intent == 'GetDay':
                    date_string = date.today().strftime("%m/%d/%Y")
                    # Check for entities
                    if len(entities) > 0:
                        # Check for a Date entity
                        for entity in entities:
                            if 'Date' == entity["category"]:
                                # Regex entities are strings, get the first one
                                date_string = entity["text"]
                    # Get the day for the specified date
                    print(GetDay(date_string))

                elif top_intent == 'GetDate':
                    day = 'today'
                    # Check for entities
                    if len(entities) > 0:
                        # Check for a Weekday entity
                        for entity in entities:
                            if 'Weekday' == entity["category"]:
                            # List entities are lists
                                day = entity["text"]
                    # Get the date for the specified day
                    print(GetDate(day))

                else:
                    # Some other intent (for example, "None") was predicted
                    print('Try asking me for the time, the day, or the date.')

    except Exception as ex:
        print(ex)


def GetTime(location):
    time_string = ''

    # Note: To keep things simple, we'll ignore daylight savings time and support only a few cities.
    # In a real app, you'd likely use a web service API (or write  more complex code!)
    # Hopefully this simplified example is enough to get the the idea that you
    # use LU to determine the intent and entities, then implement the appropriate logic

    if location.lower() == 'local':
        now = datetime.now()
        time_string = '{}:{:02d}'.format(now.hour,now.minute)
    elif location.lower() == 'london':
        utc = datetime.now(timezone.utc)
        time_string = '{}:{:02d}'.format(utc.hour,utc.minute)
    elif location.lower() == 'sydney':
        time = datetime.now(timezone.utc) + timedelta(hours=11)
        time_string = '{}:{:02d}'.format(time.hour,time.minute)
    elif location.lower() == 'new york':
        time = datetime.now(timezone.utc) + timedelta(hours=-5)
        time_string = '{}:{:02d}'.format(time.hour,time.minute)
    elif location.lower() == 'nairobi':
        time = datetime.now(timezone.utc) + timedelta(hours=3)
        time_string = '{}:{:02d}'.format(time.hour,time.minute)
    elif location.lower() == 'tokyo':
        time = datetime.now(timezone.utc) + timedelta(hours=9)
        time_string = '{}:{:02d}'.format(time.hour,time.minute)
    elif location.lower() == 'delhi':
        time = datetime.now(timezone.utc) + timedelta(hours=5.5)
        time_string = '{}:{:02d}'.format(time.hour,time.minute)
    else:
        time_string = "I don't know what time it is in {}".format(location)
    
    return time_string

def GetDate(day):
    date_string = 'I can only determine dates for today or named days of the week.'

    weekdays = {
        "monday":0,
        "tuesday":1,
        "wednesday":2,
        "thursday":3,
        "friday":4,
        "saturday":5,
        "sunday":6
    }

    today = date.today()

    # To keep things simple, assume the named day is in the current week (Sunday to Saturday)
    day = day.lower()
    if day == 'today':
        date_string = today.strftime("%m/%d/%Y")
    elif day in weekdays:
        todayNum = today.weekday()
        weekDayNum = weekdays[day]
        offset = weekDayNum - todayNum
        date_string = (today + timedelta(days=offset)).strftime("%m/%d/%Y")

    return date_string

def GetDay(date_string):
    # Note: To keep things simple, dates must be entered in US format (MM/DD/YYYY)
    try:
        date_object = datetime.strptime(date_string, "%m/%d/%Y")
        day_string = date_object.strftime("%A")
    except:
        day_string = 'Enter a date in MM/DD/YYYY format.'
    return day_string

if __name__ == "__main__":
    main()

```
- Clock.json
```json 
{
    "api-version": "2021-11-01-preview",
    "metadata": {
        "name": "Clock",
        "description": "Natural language clock",
        "type": "Conversation",
        "multilingual": false,
        "language": "en-us",
        "settings": {
            "confidenceThreshold": 0
        }
    },
    "assets": {
        "intents": [
            {
                "name": "None"
            },
            {
                "name": "GetTime"
            },
            {
                "name": "GetDay"
            },
            {
                "name": "GetDate"
            }
        ],
        "entities": [
            {
                "name": "Location",
                "compositionSetting": "ReturnLongestOverlap",
                "list": null,
                "prebuiltEntities": null
            },
            {
                "name": "Weekday",
                "compositionSetting": "ReturnLongestOverlap",
                "list": {
                    "sublists": [
                        {
                            "listKey": "Saturday",
                            "synonyms": [
                                {
                                    "language": "en-us",
                                    "values": [
                                        "Sat"
                                    ]
                                }
                            ]
                        },
                        {
                            "listKey": "Friday",
                            "synonyms": [
                                {
                                    "language": "en-us",
                                    "values": [
                                        "Fri"
                                    ]
                                }
                            ]
                        },
                        {
                            "listKey": "Thursday",
                            "synonyms": [
                                {
                                    "language": "en-us",
                                    "values": [
                                        "Thu",
                                        "Thur",
                                        "Thurs"
                                    ]
                                }
                            ]
                        },
                        {
                            "listKey": "Wednesday",
                            "synonyms": [
                                {
                                    "language": "en-us",
                                    "values": [
                                        "Wed",
                                        "Weds"
                                    ]
                                }
                            ]
                        },
                        {
                            "listKey": "Tuesday",
                            "synonyms": [
                                {
                                    "language": "en-us",
                                    "values": [
                                        "Tue",
                                        "Tues"
                                    ]
                                }
                            ]
                        },
                        {
                            "listKey": "Monday",
                            "synonyms": [
                                {
                                    "language": "en-us",
                                    "values": [
                                        "Mon"
                                    ]
                                }
                            ]
                        },
                        {
                            "listKey": "Sunday",
                            "synonyms": [
                                {
                                    "language": "en-us",
                                    "values": [
                                        "Sun"
                                    ]
                                }
                            ]
                        }
                    ]
                },
                "prebuiltEntities": null
            },
            {
                "name": "Date",
                "compositionSetting": "ReturnLongestOverlap",
                "list": null,
                "prebuiltEntities": [
                    {
                        "displayName": "DateTime",
                        "semanticType": "DateTime",
                        "semanticSubtype": null
                    }
                ]
            }
        ],
        "examples": [
            {
                "text": "what day will it be on Dec 31st 2099?",
                "language": "en-us",
                "intent": "GetDay",
                "entities": [
                    {
                        "entityName": "Date",
                        "offset": 23,
                        "length": 13
                    }
                ],
                "dataset": "Train"
            },
            {
                "text": "what day was 01/01/1901?",
                "language": "en-us",
                "intent": "GetDay",
                "entities": [
                    {
                        "entityName": "Date",
                        "offset": 13,
                        "length": 10
                    }
                ],
                "dataset": "Train"
            },
            {
                "text": "what will the date be on Thurs?",
                "language": "en-us",
                "intent": "GetDate",
                "entities": [
                    {
                        "entityName": "Weekday",
                        "offset": 25,
                        "length": 5
                    }
                ],
                "dataset": "Train"
            },
            {
                "text": "what date will it be on Friday?",
                "language": "en-us",
                "intent": "GetDate",
                "entities": [
                    {
                        "entityName": "Weekday",
                        "offset": 24,
                        "length": 6
                    }
                ],
                "dataset": "Train"
            },
            {
                "text": "what date was it on Saturday?",
                "language": "en-us",
                "intent": "GetDate",
                "entities": [
                    {
                        "entityName": "Weekday",
                        "offset": 20,
                        "length": 8
                    }
                ],
                "dataset": "Train"
            },
            {
                "text": "what's the time in New York?",
                "language": "en-us",
                "intent": "GetTime",
                "entities": [
                    {
                        "entityName": "Location",
                        "offset": 19,
                        "length": 8
                    }
                ],
                "dataset": "Train"
            },
            {
                "text": "tell me the time in Paris?",
                "language": "en-us",
                "intent": "GetTime",
                "entities": [
                    {
                        "entityName": "Location",
                        "offset": 20,
                        "length": 5
                    }
                ],
                "dataset": "Train"
            },
            {
                "text": "what time is it in London?",
                "language": "en-us",
                "intent": "GetTime",
                "entities": [
                    {
                        "entityName": "Location",
                        "offset": 19,
                        "length": 6
                    }
                ],
                "dataset": "Train"
            },
            {
                "text": "what's today's date?",
                "language": "en-us",
                "intent": "GetDate",
                "entities": [],
                "dataset": "Train"
            },
            {
                "text": "what is the date today?",
                "language": "en-us",
                "intent": "GetDate",
                "entities": [],
                "dataset": "Train"
            },
            {
                "text": "what's the date?",
                "language": "en-us",
                "intent": "GetDate",
                "entities": [],
                "dataset": "Train"
            },
            {
                "text": "what date is it?",
                "language": "en-us",
                "intent": "GetDate",
                "entities": [],
                "dataset": "Train"
            },
            {
                "text": "what day of the week is it?",
                "language": "en-us",
                "intent": "GetDay",
                "entities": [],
                "dataset": "Train"
            },
            {
                "text": "what is the day today?",
                "language": "en-us",
                "intent": "GetDay",
                "entities": [],
                "dataset": "Train"
            },
            {
                "text": "what's the day?",
                "language": "en-us",
                "intent": "GetDay",
                "entities": [],
                "dataset": "Train"
            },
            {
                "text": "what day is it?",
                "language": "en-us",
                "intent": "GetDay",
                "entities": [],
                "dataset": "Train"
            },
            {
                "text": "tell me the time",
                "language": "en-us",
                "intent": "GetTime",
                "entities": [],
                "dataset": "Train"
            },
            {
                "text": "what time is it?",
                "language": "en-us",
                "intent": "GetTime",
                "entities": [],
                "dataset": "Train"
            },
            {
                "text": "what's the time?",
                "language": "en-us",
                "intent": "GetTime",
                "entities": [],
                "dataset": "Train"
            },
            {
                "text": "what is the time?",
                "language": "en-us",
                "intent": "GetTime",
                "entities": [],
                "dataset": "Train"
            }
        ]
    }
}
```

