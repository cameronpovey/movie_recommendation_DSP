import json, firebase_admin, requests
from firebase_admin import credentials, db


cred = credentials.Certificate('serviceKey.json')
firebase_admin.initialize_app(cred, {'databaseURL': 'https://cohesive-memory-342803-default-rtdb.europe-west1.firebasedatabase.app/'})

ref = db.reference('/')

data = ref.get()


for film in data:
    print(data[film])
    id = data[film]['id']
    url = "https://api.themoviedb.org/3/movie/"+str(id)+"/keywords"
    response = requests.get(url, headers=headers)
    newData = response.text
    newData_dict = json.loads(newData)

    url2 = "https://api.themoviedb.org/3/movie/"+str(id)+"/credits?language=en-US"
    response = requests.get(url2, headers=headers)
    newData = response.text
    credits = json.loads(newData)

    doc = db.reference('/'+str(film))
    print(credits)
    doc.update({'keywords':newData_dict['keywords'], 'cast':credits['cast'][:10], 'crew':credits['crew'][:10]})







