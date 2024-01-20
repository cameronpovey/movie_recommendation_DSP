import functions_framework
import firebase_admin
from firebase_admin import credentials, db
from google.cloud import firestore

#TEST USED WITH API

# http://localhost:8080/?name=YourName

@functions_framework.http
def getData(request):
    #ARGS FOR HTTP REQUEST
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_args and 'id' in request_args:
        ratings = getRatings(request_args['id'])
        print("________________")
        print(ratings)
        return ratings
    else:
        return 'ERROR'

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
        print(f'Document ID: {doc.id}, Data: {data}')

    return ratings
    


def getFilms(id):
    if not firebase_admin._apps:
        cred = credentials.Certificate('serviceKey.json')
        firebase_admin.initialize_app(cred, {'databaseURL': 'https://cohesive-memory-342803-default-rtdb.europe-west1.firebasedatabase.app/'})

    ref = db.reference(f'/{id}/')
    data = ref.get()
    return data