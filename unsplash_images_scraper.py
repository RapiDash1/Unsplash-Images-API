import requests
import json

source = requests.get('https://api.unsplash.com/search/photos?page=1&query=office&client_id=58a49a96047b4e89683aba566e7422ec23c5cb3a120df66f94962d0df07bf052').text
jsonData = json.loads(source)

print(jsonData['results'][0]['urls'])


