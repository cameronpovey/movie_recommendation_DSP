import functions_framework
import firebase_admin
from firebase_admin import credentials, db
from google.cloud import firestore

#TEST USED WITH API

# http://localhost:8080/?name=YourName

@functions_framework.http
def startRec(request):
    #ARGS FOR HTTP REQUEST
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_args and 'id' in request_args:
        ratings = getRatings(request_args['id'])

        used = []
        for id in ratings:
            used.append(id)

        genres = getGen(ratings)
        reccs = findGen(genres, used)

        out = {}
        out['reccs'] = {}
        out['rated'] = {}
        for film in reccs:
            out['reccs'][film] = {}
            out['reccs'][film]['title'] = reccs[film]['title']
            out['reccs'][film]['genreScore'] = reccs[film]['genreScore']
            
        for movie in ratings:
            out['rated'][movie] = {}
            out['rated'][movie]['title'] = ratings[movie]['film_data']['title']
            out['rated'][movie]['rating'] = ratings[movie]['rating']

        return reccs
    else:
        return 'ERROR'

def findGen(genres, used):
    weight = 0
    # 0 for standard weights
    # increase for dramatic weights

    count = 0
    filmData = {}
    if not firebase_admin._apps:
        cred = credentials.Certificate('serviceKey.json')
        firebase_admin.initialize_app(cred, {'databaseURL': 'https://cohesive-memory-342803-default-rtdb.europe-west1.firebasedatabase.app/'})

    ref = db.reference(f'/')
    data = ref.get()

    for filmid in list(data.keys()):
        if filmid in used:
            del data[filmid]
            continue

        diversity = 0
        genreScore = 0

        filmGen = data[filmid]['genres']
        
        for i, genre in enumerate(filmGen):
            if genre in genres:
                factor = ((len(filmGen) - i - 1)*weight *0.1) + 1
                weightRate = genres[genre]['avg']*factor
                genreScore = genreScore + weightRate
            else:
                diversity = diversity + 1

        data[filmid]['genreScore'] = genreScore/len(genres)
        data[filmid]['diversityScore'] = diversity

    sorted_data = sorted(data.items(), key=lambda item: item[1]['genreScore'], reverse=True)

    output = dict(sorted_data[:20])

    for genre in genres:
        print(genre, ' - ', genres[genre])
        
    print("---------------------")

    for recc in output:
        print(output[recc]['title'], ' - ', output[recc]['genreScore'])

    return output

def getGen(ratings):
    weight = 0
    # 0 for standard weights
    # increase for dramatic weights
    genres = {}
    
    for movie in ratings:
        print(ratings[movie]['film_data']['title'], ' - ', ratings[movie]['rating'])
        filmRate = ratings[movie]['rating']
        filmGen = ratings[movie]['film_data']['genres']
        
        if filmRate == 'bookmark':
            filmRate = 7

        elif filmRate == 'ignore':
            filmRate = 0

        for i, genre in enumerate(filmGen):
            factor = ((len(filmGen) - i - 1)*weight *0.1) + 1

            weightRate = filmRate*factor
            
            if genre in genres:
                genres[genre]['size'] = genres[genre]['size'] + 1
                genres[genre]['total'] = genres[genre]['total'] + (weightRate)
                genres[genre]['avg'] = genres[genre]['total'] / genres[genre]['size']
            else:
                genres[genre] = {'size': 1, 'total': weightRate, 'avg': weightRate/1}

    print("---------------------")
    return genres

def getRatings(uid):
    ratings = {}
    db = firestore.Client.from_service_account_json('serviceKey.json')
    docRef = db.collection('Users').document(uid).collection('Ratings')

    # Get all documents in the Ratings collection
    all_docs = docRef.stream()

    # Iterate over the documents and print their data
    for doc in all_docs:
        data = doc.to_dict()
        data['film_data'] = getFilms(doc.id)
        ratings[doc.id] = data
        print(doc.id)
        #print(f'Document ID: {doc.id}, Data: {data}')

    return ratings
    
def getFilms(id):
    if not firebase_admin._apps:
        cred = credentials.Certificate('serviceKey.json')
        firebase_admin.initialize_app(cred, {'databaseURL': 'https://cohesive-memory-342803-default-rtdb.europe-west1.firebasedatabase.app/'})

    ref = db.reference(f'/{id}/')
    data = ref.get()
    return data