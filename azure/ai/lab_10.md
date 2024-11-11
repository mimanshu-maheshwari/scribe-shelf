## Lab 10(Utilize prompt engineering in your app):
https://github.com/MicrosoftLearning/mslearn-openai
```cmd 
pip install openai==1.13.3
```
```dotenv []
AZURE_OAI_ENDPOINT="https://azure-openai-demo-mm-1.openai.azure.com/openai/deployments/gpt-35-turbo-lab-10-prompt-engineering/chat/completions?api-version=2024-08-01-preview"
AZURE_OAI_KEY="AWmOlOGIScml7DHjJQ4tDMYEDeIRRywMGvmWtgi8KJWWm7lzmn6FJQQJ99AKACYeBjFXJ3w3AAABACOGndBB"
AZURE_OAI_DEPLOYMENT="gpt-35-turbo-lab-10-prompt-engineering"
```
```python []
import os
import asyncio
from dotenv import load_dotenv

# Add Azure OpenAI package
from openai import AsyncAzureOpenAI


# Set to True to print the full response from OpenAI for each call
printFullResponse = False

async def main(): 
        
    try: 
    
        # Get configuration settings 
        load_dotenv()
        azure_oai_endpoint = os.getenv("AZURE_OAI_ENDPOINT")
        azure_oai_key = os.getenv("AZURE_OAI_KEY")
        azure_oai_deployment = os.getenv("AZURE_OAI_DEPLOYMENT")
        
        # Configure the Azure OpenAI client
        client = AsyncAzureOpenAI(
            azure_endpoint = azure_oai_endpoint, 
            api_key=azure_oai_key,  
            api_version="2024-02-15-preview"
            )
        

        while True:
            # Pause the app to allow the user to enter the system prompt
            print("------------------
Pausing the app to allow you to change the system prompt.
Press enter to continue...")
            input()

            # Read in system message and prompt for user message
            system_text = open(file="system.txt", encoding="utf8").read().strip()
            user_text = input("Enter user message, or 'quit' to exit: ")
            if user_text.lower() == 'quit' or system_text.lower() == 'quit':
                print('Exiting program...')
                break
            
            await call_openai_model(system_message = system_text, 
                                    user_message = user_text, 
                                    model=azure_oai_deployment, 
                                    client=client
                                    )

    except Exception as ex:
        print(ex)

async def call_openai_model(system_message, user_message, model, client):

    # Format and send the request to the model
		# Add grounding message
		print("\nAdding grounding context from grounding.txt")
		grounding_text = open(file="grounding.txt", encoding="utf8").read().strip()    
		user_message = grounding_text + user_message

    # Formsystemat and send the request to the model
    messages =[
        {"role": "system", "content": system_message},
        {"role": "user", "content": user_message},
    ]

    print("
Sending request to Azure OpenAI model...
")

    # Call the Azure OpenAI model
    response = await client.chat.completions.create(
        model=model,
        messages=messages,
        temperature=0.7,
        max_tokens=800
    )


    if printFullResponse:
        print(response)

    print("Response:
" + response.choices[0].message.content + "
")

if __name__ == '__main__': 
    asyncio.run(main())

```
- Grounding.txt
```text []
Contoso is a wildlife rescue organization that has dedicated itself to the protection and preservation of animals and their habitats. The organization has been working tirelessly to protect the wildlife and their habitats from the threat of extinction. Contoso's mission is to provide a safe and healthy environment for all animals in their care.

One of the most popular animals that Contoso rescues and cares for is the red panda. Known for their fluffy tails and adorable faces, red pandas have captured the hearts of children all over the world. These playful creatures are native to the Himalayas and are listed as endangered due to habitat loss and poaching.

Contoso's red panda rescue program is one of their most successful initiatives. The organization works with local communities to protect the red panda's natural habitat and provides medical care for those that are rescued. Contoso's team of experts works tirelessly to ensure that all rescued red pandas receive the best possible care and are eventually released back into the wild.

Children, in particular, have a soft spot for red pandas. These playful creatures are often featured in children's books, cartoons, and movies. With their fluffy tails and bright eyes, it's easy to see why children are drawn to them. Contoso understands this and has made it their mission to educate children about the importance of wildlife conservation and the role they can play in protecting these endangered species.

Contoso's red panda rescue program is not only helping to save these adorable creatures from extinction but is also providing a unique opportunity for children to learn about wildlife conservation. The organization offers educational programs and tours that allow children to get up close and personal with the red pandas. These programs are designed to teach children about the importance of protecting wildlife and their habitats.

In addition to their red panda rescue program, Contoso also rescues and cares for a variety of other animals, including elephants, tigers, and rhinoceros. The organization is committed to protecting all animals in their care and works tirelessly to provide them with a safe and healthy environment
```
- System text
```text []
You are helpfull assistant.
```


