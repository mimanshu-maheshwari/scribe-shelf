
### Lab 1:

#### ai services

- create a azure ai multi-service account
- in the created service we have http endpoint, keys, location
- headers:

```json
{
  "Content-type": "application/json",
  "Ocp-Apim-Subscription-key": "<key>"
}
```

- data:

```json
{
  "documents": [{ "id": 1, "text": "<text>" }]
}
```

- /text/analytics/v3.1/languages?
- AzureKeyCredential
- TextAnalyticsClient
- .env:
  ```dotenv
  AI_SERVICE_ENDPOINT=YOUR_AI_SERVICES_ENDPOINT
  AI_SERVICE_KEY=YOUR_AI_SERVICES_KEY
  ```
- rest-client.py:

  ```python
  from dotenv import load_dotenv
  import os
  import http.client, base64, json, urllib
  from urllib import request, parse, error
  def main():
  	global ai_endpoint
  	global ai_key
  	try:
  		# Get Configuration Settings
  		load_dotenv()
  		ai_endpoint = os.getenv('AI_SERVICE_ENDPOINT')
  		ai_key = os.getenv('AI_SERVICE_KEY')
  		# Get user input (until they enter "quit")
  		userText =''
  		while userText.lower() != 'quit':
  			userText = input('Enter some text ("quit" to stop)\n')
  			if userText.lower() != 'quit':
  				GetLanguage(userText)
  	except Exception as ex:
  		print(ex)

  def GetLanguage(text):
  	try:
  	# Construct the JSON request body (a collection of documents, each with an ID and text)
  	jsonBody = {
  		"documents":[ {"id": 1, "text": text}]}
  		# Let's take a look at the JSON we'll send to the service
  		print(json.dumps(jsonBody, indent=2))
  		# Make an HTTP request to the REST interface
  		uri = ai_endpoint.rstrip('/').replace('https://', '')
  		conn = http.client.HTTPSConnection(uri)
  		# Add the authentication key to the request header
  		headers = {'Content-Type': 'application/json','Ocp-Apim-Subscription-Key': ai_key}
  		# Use the Text Analytics language API
  		conn.request("POST", "/text/analytics/v3.1/languages?", str(jsonBody).encode('utf-8'), headers)
  		# Send the request
  		response = conn.getresponse()
  		data = response.read().decode("UTF-8")
  		# If the call was successful, get the response
  		if response.status == 200:
  			# Display the JSON response in full (just so we can see it)
  			results = json.loads(data)
  			print(json.dumps(results, indent=2))
  			# Extract the detected language name for each document
  			for document in results["documents"]:
  				print("\nLanguage:", document["detectedLanguage"]["name"])
  		else:
  			# Something went wrong, write the whole response
  			print(data)
  		conn.close()
  	except Exception as ex:
  		print(ex)

  if __name__ == "__main__":
  	main()
  ```

- sdk-client.py:

  ```python
  from dotenv import load_dotenv
  import osfrom azure.core.credentials
  import AzureKeyCredentialfrom azure.ai.textanalytics
  import TextAnalyticsClient
  def main():
  	global ai_endpoint
  	global ai_key
  	try:
  		# Get Configuration Settings
  		load_dotenv()
  		ai_endpoint = os.getenv('AI_SERVICE_ENDPOINT')
  		ai_key = os.getenv('AI_SERVICE_KEY')
  		# Get user input (until they enter "quit")
  		userText =''
  		while userText.lower() != 'quit':
  			userText = input('\nEnter some text ("quit" to stop)\n')
  			if userText.lower() != 'quit':
  				language = GetLanguage(userText)
  				print('Language:', language)
  	except Exception as ex:
  		print(ex)

  def GetLanguage(text):
  	# Create client using endpoint and key
  	credential = AzureKeyCredential(ai_key)
  	client = TextAnalyticsClient(endpoint=ai_endpoint, credential=credential)
  	# Call the service to get the detected language
  	detectedLanguage = client.detect_language(documents = [text])[0]
  	return detectedLanguage.primary_language.name

  if __name__ == "__main__":
  	main()
  ```

#### service security:

- keyvault-client.py
- .env:
  ```dotenv
  AI_SERVICE_ENDPOINT=your_ai_services_endpoint
  KEY_VAULT=your_key_vault_name
  TENANT_ID=your_service_principal_tenant_id
  APP_ID=your_service_principal_app_id
  APP_PASSWORD=your_service_principal_password
  ```
- keyvault-client.py

  ```python
  from dotenv import load_dotenv
  import os
  from azure.ai.textanalytics
  import TextAnalyticsClientfrom azure.core.credentials import AzureKeyCredential
  from azure.keyvault.secrets import SecretClient
  from azure.identity import ClientSecretCredential
  def main():
  	global ai_endpoint
  	global cog_key
  	try:
  		# Get Configuration Settings
  		load_dotenv()
  		ai_endpoint = os.getenv('AI_SERVICE_ENDPOINT')
  		key_vault_name = os.getenv('KEY_VAULT')
  		app_tenant = os.getenv('TENANT_ID')
  		app_id = os.getenv('APP_ID')
  		app_password = os.getenv('APP_PASSWORD')
  		# Get Azure AI services key from keyvault using the service principal credentials
  		key_vault_uri = f"https://{key_vault_name}.vault.azure.net/"
  		credential = ClientSecretCredential(app_tenant, app_id, app_password)
  		keyvault_client = SecretClient(key_vault_uri, credential)
  		secret_key = keyvault_client.get_secret("AI-Services-Key")
  		cog_key = secret_key.value
  		# Get user input (until they enter "quit")
  		userText =''
  		while userText.lower() != 'quit':
  			userText = input('\nEnter some text ("quit" to stop)\n')
  			if userText.lower() != 'quit':
  				language = GetLanguage(userText)
  				print('Language:', language)
  	except Exception as ex:
  		print(ex)

  def GetLanguage(text):
  	# Create client using endpoint and key
  	credential = AzureKeyCredential(cog_key)
  	client = TextAnalyticsClient(endpoint=ai_endpoint, credential=credential)
  	# Call the service to get the detected language
  	detectedLanguage = client.detect_language(documents = [text])[0]
  	return detectedLanguage.primary_language.name

  if __name__ == "__main__":
  	main()
  ```

- rest-test.cmd

  ```cmd
  curl -X POST "<your-endpoint>/language/:analyze-text?api-version=2023-04-01" -H "Content-Type: application/json" -H "Ocp-Apim-Subscription-Key: <your-key>" --data-ascii "{'analysisInput':{'documents':[{'id':1,'text':'hello'}]}, 'kind': 'LanguageDetection'}"
  ```

- rest-test.sh
  ```sh
  curl -X POST "<your-endpoint>/text/analytics/v3.1/languages?'" -H "Content-Type: application/json" -H "Ocp-Apim-Subscription-Key: <your-key>" --data-ascii "{'documents':[{'id':1,'text':'hello'}]}"
  ```


