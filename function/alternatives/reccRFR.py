import functions_framework
import firebase_admin
from datetime import datetime
from firebase_admin import credentials, db
from google.cloud import firestore

#linear
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler, OneHotEncoder
import pandas as pd

@functions_framework.http
def startRec(request):
    #ARGS FOR HTTP REQUEST
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_args and 'id' in request_args:
        #get rated films
        ratings = getRatings(request_args['id'])

        #list used films
        used = []
        for id in ratings:
            print(ratings[id]['film_data']['title'], ' - ', ratings[id]['rating'])
            used.append(id)

        #pre-process data
        features = []
        data = []

        #multiple categories
        actors_set = set()
        crew_set = set()
        genres_set = set()
        keywords_set = set()
        
        for movie in ratings:
            print(ratings[movie])
            if ratings[movie]['rating'] == 'bookmark':
                ratings[movie]['rating'] = 7
            elif ratings[movie]['rating'] == 'ignore':
                ratings[movie]['rating'] = 0
                
            actors = [actor['id'] for actor in ratings[movie]['film_data']['cast']]
            actors_set.update(actors)

            crew = [crew['id'] for crew in ratings[movie]['film_data']['crew']]
            crew_set.update(crew)
            
            genres = [genre for genre in ratings[movie]['film_data']['genre_ids']]
            genres_set.update(genres)
            
            if 'keywords' in ratings[movie]['film_data']:
                keywords = [keyword['id'] for keyword in ratings[movie]['film_data']['keywords']]
                keywords_set.update(keywords)

            release_year = int(ratings[movie]['film_data']['release_date'].split('-')[0])
            
            # Append features for this movie
            data.append([release_year] + [ratings[movie]['film_data'][feature] for feature in features])

            

        #PANDDADDDDSSSS
        df = pd.DataFrame(data)

        #CATEGORIES
        # One-hot encode actors
        for actor_id in actors_set:
            df['actor_' + str(actor_id)] = 0

        for i, movie in enumerate(ratings):
            for actor in ratings[movie]['film_data']['cast']:
                actor_id = actor['id']
                df.at[i, 'actor_' + str(actor_id)] = 1

        # One-hot encode crew
        for crew_id in crew_set:
            df['crew_' + str(crew_id)] = 0

        for i, movie in enumerate(ratings):
            for crew in ratings[movie]['film_data']['crew']:
                crew_id = crew['id']
                df.at[i, 'crew_' + str(crew_id)] = 1
        
        # One-hot encode genres
        for genre_id in genres_set:
            df['genre_' + str(genre_id)] = 0

        for i, movie in enumerate(ratings):
            for genre_id in ratings[movie]['film_data']['genre_ids']:
                df.at[i, 'genre_' + str(genre_id)] = 1
        
        # One-hot encode keywords
        for keyword_id in keywords_set:
            df['keyword_' + str(keyword_id)] = 0

        for i, movie in enumerate(ratings):
            if 'keywords' in ratings[movie]['film_data']:
                for keyword in ratings[movie]['film_data']['keywords']:
                    keyword_id = keyword['id']
                    df.at[i, 'keyword_' + str(keyword_id)] = 1

        rates = [ratings[movie]['rating'] for movie in ratings]

        print(df)
        print(rates)

        #Train Model
        model = RandomForestRegressor(n_estimators=1000, random_state=42)  # Initialize Random Forest

        #New Data
        new_ratings = newFilms(used)

        new_data = []

        new_actors_set = set()
        new_crew_set = set()
        new_genres_set = set()
        new_keywords_set = set()

        for movie_id, movie_data in new_ratings.items():
            actors = [actor['id'] for actor in movie_data['cast']]
            new_actors_set.update(actors)

            crew = [crew['id'] for crew in movie_data['crew']]
            new_crew_set.update(crew)
            
            genres = movie_data['genre_ids']
            new_genres_set.update(genres)
            
            if 'keywords' in movie_data:
                keywords = [keyword['id'] for keyword in movie_data['keywords']]
                new_keywords_set.update(keywords)

            release_year = int(movie_data['release_date'].split('-')[0])
            
            # Append features for this movie
            new_data.append([release_year] + [movie_data[feature] for feature in features])

        # Create a DataFrame for new data
        new_df = pd.DataFrame(new_data)

        # One-hot encode actors
        for actor_id in new_actors_set:
            new_df['actor_' + str(actor_id)] = 0

        for i, movie_id in enumerate(new_ratings):
            for actor in new_ratings[movie_id]['cast']:
                actor_id = actor['id']
                new_df.at[i, 'actor_' + str(actor_id)] = 1

        # One-hot encode crew
        for crew_id in new_crew_set:
            new_df['crew_' + str(crew_id)] = 0

        for i, movie in enumerate(new_ratings):
            for crew in new_ratings[movie_id]['crew']:
                crew_id = crew['id']
                new_df.at[i, 'crew_' + str(crew_id)] = 1

        # One-hot encode genres
        for genre_id in new_genres_set:
            new_df['genre_' + str(genre_id)] = 0

        for i, movie_id in enumerate(new_ratings):
            for genre_id in new_ratings[movie_id]['genre_ids']:
                new_df.at[i, 'genre_' + str(genre_id)] = 1

        # One-hot encode keywords
        for keyword_id in new_keywords_set:
            new_df['keyword_' + str(keyword_id)] = 0

        for i, movie_id in enumerate(new_ratings):
            if 'keywords' in new_ratings[movie_id]:
                for keyword in new_ratings[movie_id]['keywords']:
                    keyword_id = keyword['id']
                    new_df.at[i, 'keyword_' + str(keyword_id)] = 1

        # Convert column names to strings
        df.columns = df.columns.astype(str)
        df.rename(columns={0: 'release_year'}, inplace=True)
        new_df.rename(columns={0: 'release_year'}, inplace=True)

        for col in df.columns:
            if col not in new_df.columns:
                new_df[col] = 0

        for col in new_df.columns:
            if col not in df.columns:
                df[col] = 0

        df = df.reindex(sorted(df.columns), axis=1)
        new_df = new_df.reindex(sorted(new_df.columns), axis=1)

        model.fit(df, rates)

        predicted_ratings = model.predict(new_df)
        print(predicted_ratings)

        top_indices = sorted(range(len(predicted_ratings)), key=lambda i: predicted_ratings[i], reverse=True)

        # Retrieve the corresponding items and their ratings from the original data
        top_predictions_with_ratings = [(list(new_ratings.keys())[i], predicted_ratings[i]) for i in top_indices][:10]

        recc = {}

        # Print the IDs of the top 10 highest rated items
        for movie_id, rating in top_predictions_with_ratings:
            recc[movie_id] = new_ratings[movie_id]
            print(new_ratings[movie_id]['title'], rating)
            
        print("------------")

        for film in ratings:
            print(ratings[film]['film_data']['title'], ratings[film]['rating'])

        return recc
    else:
        return 'ERROR'

def newFilms(used):
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

    return data

#ALWAYS KEEP SAME
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