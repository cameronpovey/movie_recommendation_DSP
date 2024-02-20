import json
import firebase_admin
from firebase_admin import credentials, db


with open('generate/film.json', 'r') as file:
    films = json.load(file)

with open('generate/genres.json', 'r') as genresFile:
    genres = json.load(genresFile)

print(f'No Films: {len(films)}')
print("------------------------------")

unique=[]

def checkGenres(gID):
    for genre in genres:
        if genre['id'] == gID:
            return genre['name']

for film in films:
    if film not in unique:
        film['genres'] = []
        for ids in film['genre_ids']:
            film['genres'].append(checkGenres(ids))
        unique.append(film)
    else:
        print(film['title'] + ' - already used')
        continue

films = unique
print("------------------------------")
print(f'No Unique Films: {len(films)}')


cred = credentials.Certificate('serviceKey.json')
firebase_admin.initialize_app(cred, {'databaseURL': 'https://cohesive-memory-342803-default-rtdb.europe-west1.firebasedatabase.app/'})

ref = db.reference('/')

for film in films:
    newItem = ref.push()
    newItem.set(film)