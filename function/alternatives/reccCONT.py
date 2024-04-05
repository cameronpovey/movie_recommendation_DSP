import functions_framework
import firebase_admin
from datetime import datetime
from firebase_admin import credentials, db
from google.cloud import firestore
import random

@functions_framework.http
def startRec(request):
    #ARGS FOR HTTP REQUEST
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_args and 'id' in request_args:
        ratings = getRatings(request_args['id'])

        used = []
        keys_to_remove = []
        for id in ratings:
            if ratings[id]['rating'] == 'remove':
                keys_to_remove.append(id)
                continue
            print(ratings[id]['film_data']['title'], ' - ', ratings[id]['rating'])
            used.append(id)

        for key in keys_to_remove:
            del ratings[key]

        genres = getGen(ratings)
        gen_W = getAttWeight(genres)

        actors = getActors(ratings)
        act_W = getAttWeight(actors)

        crew = getCrew(ratings)
        crew_W = getAttWeight(crew)
        
        keywords = getKeywords(ratings)
        key_w = getAttWeight(keywords)

        years = getYears(ratings)
        year_w = getAttWeight(years)

        print(f'GEN W: {gen_W} ------ ACT W: {act_W} ------ CREW W: {crew_W} ------ KEY W: {key_w} ------ YEAR W: {year_w}')

        reccs = findScore({'genres': {'data': genres, 'weight': gen_W}, 'actors': {'data': actors, 'weight': act_W}, 'crew': {'data': crew, 'weight': crew_W}, 'keywords': {'data': keywords, 'weight': key_w}, 'years': {'data': years, 'weight': year_w}}, used)

        out = {}
        out['reccs'] = {}
        out['rated'] = {}

        #REDO
        for film in reccs:
            if 'reccScore' not in reccs[film]:
                continue
            out['reccs'][film] = {}
            out['reccs'][film]['title'] = reccs[film]['title']
            out['reccs'][film]['genreScore'] = reccs[film]['genreScore']
            
        for movie in ratings:
            if 'reccScore' not in reccs[film]:
                continue
            out['rated'][movie] = {}
            out['rated'][movie]['title'] = ratings[movie]['film_data']['title']
            out['rated'][movie]['rating'] = ratings[movie]['rating']

        return reccs
    else:
        return 'ERROR'
    
def randomFilms(amount, used, data):
    filmData = {}
    pointers = random.sample(range(0, len(data)), amount)
    for i, film in enumerate(data):
        if film in used:
            continue
        if i in pointers:
            filmData[film] = data[film]
    return filmData


#rates all movies
def findScore(rateData, used):
    genres = rateData['genres']['data']
    genWeight = rateData['genres']['weight']

    actors = rateData['actors']['data']
    actWeight = rateData['actors']['weight']

    crew = rateData['crew']['data']
    crewWeight = rateData['crew']['weight']

    keywords = rateData['keywords']['data']
    keyWeight = rateData['keywords']['weight']

    years = rateData['years']['data']
    yearWeight = rateData['years']['weight']

    if not firebase_admin._apps:
        cred = credentials.Certificate('serviceKey.json')
        firebase_admin.initialize_app(cred, {'databaseURL': 'https://cohesive-memory-342803-default-rtdb.europe-west1.firebasedatabase.app/'})

    ref = db.reference(f'/')
    data = ref.get()

    if len(used) == 0:
        return randomFilms(len(data), used, data)
        


    for filmid in list(data.keys()):
        if filmid in used:
            del data[filmid]
            continue

        diversity = 0
        genreScore = 0
        actorScore = 0
        crewScore = 0
        keywordScore = 0
        yearScore = 0
        
        filmGen = data[filmid]['genres']
        filmAct = data[filmid]['cast']
        filmCrew = data[filmid]['crew']

        filmYear = data[filmid]['release_date']
        filmYear = datetime.strptime(filmYear, "%Y-%m-%d").year
        
        if 'keywords' not in data[filmid]: filmKey = []
        else: filmKey = data[filmid]['keywords']
        

        #genre score
        for i, genre in enumerate(filmGen):
            if genre in genres:
                factor = ((len(filmGen) - i - 1) * genWeight * 0.1) + 1
                weightRate = genres[genre]['avg']*factor
                genreScore = genreScore + weightRate
            else:
                diversity = diversity + 1
        data[filmid]['genreScore'] = genreScore/len(genres)

        #actor score
        for i, actor in enumerate(filmAct):
            act = actor['name']
            if act in actors:
                factor = ((len(filmAct) - i - 1) * actWeight * 0.1) + 1
                weightRate = actors[act]['avg']*factor
                actorScore = actorScore + weightRate
            else:
                diversity = diversity + 1
        data[filmid]['actorScore'] = actorScore/len(actors)

        #crew score
        for i, crewM in enumerate(filmCrew):
            member = crewM['name']
            if member in crew:
                factor = ((len(filmCrew) - i - 1) * crewWeight * 0.1) + 1
                weightRate = crew[member]['avg']*factor
                crewScore = crewScore + weightRate
            else:
                diversity = diversity + 1
        data[filmid]['crewScore'] = crewScore/len(crew)

        #keyword score
        for i, key in enumerate(filmKey):
            keyword = key['name']
            if keyword in keywords:
                factor = ((len(filmKey) - i - 1) * keyWeight * 0.1) + 1
                weightRate = keywords[keyword]['avg']*factor
                keywordScore = keywordScore + weightRate
            else:
                diversity = diversity + 1
        data[filmid]['keywordScore'] = keywordScore/len(keywords)

        #year score
        for i, key in enumerate(filmKey):
            keyword = key['name']
            if keyword in keywords:
                factor = ((len(filmKey) - i - 1) * keyWeight * 0.1) + 1
                weightRate = keywords[keyword]['avg']*factor
                keywordScore = keywordScore + weightRate
            else:
                diversity = diversity + 1
        data[filmid]['keywordScore'] = keywordScore/len(keywords)

        factor = (yearWeight * 0.01)
        data[filmid]['yearScore'] = years[filmYear]['avg']*factor

    

        #diversity
        data[filmid]['diversityScore'] = diversity

        #overall score
        data[filmid]['reccScore'] = data[filmid]['genreScore'] + data[filmid]['actorScore'] + data[filmid]['crewScore'] + data[filmid]['keywordScore'] + data[filmid]['yearScore']

    sorted_data = sorted(data.items(), key=lambda item: item[1]['reccScore'], reverse=True)

    output = dict(sorted_data[:10])

    for recc in output:
        print(output[recc]['title'], ' - GEN:', output[recc]['genreScore'],  ' - ACT:', output[recc]['actorScore'],  ' - CREW:', output[recc]['crewScore'],  ' - KEY:', output[recc]['keywordScore'],  ' - YEAR:', output[recc]['yearScore'],  ' - RECC:', output[recc]['reccScore'])

    #add 10 random films to output
    ranFilms = randomFilms(5, used, data)
    output.update(ranFilms)


    return output

def getAttWeight(area):
    common = {}
    total = 0
    size = 0
    for item in area:
        if area[item]['size'] > 0:
            size +=1
            total += area[item]['avg']
            common[item] = area[item]

    #cut down to just higher half
    #print(f'AVERAGE {total/size}')
    if size != 0:
        avg = int(total/size)
    else:
        avg = 0
    
    area = {}
    total = 0
    size = 0
    for item in common:
        if common[item]['avg'] > avg:
            size +=1
            total += common[item]['avg']
            area[item] = common[item]
            #print(item, ' - ', area[item])

    if size == 0:
        return 0
    
    return total/size

#gets actor ratings
def getActors(ratings):
    weight = 0
    # 0 for standard weights
    # increase for dramatic weights
    actors = {}
    
    for movie in ratings:
        filmRate = ratings[movie]['rating']
        filmAct = ratings[movie]['film_data']['cast']
        filmAct = filmAct[:int(len(filmAct)/2)]
        
        if filmRate == 'bookmark':
            filmRate = 7

        elif filmRate == 'ignore':
            filmRate = 0

        for i, actorint in enumerate(filmAct):
            actor = actorint['name']
            factor = ((len(filmAct) - i - 1)*weight *0.1) + 1

            weightRate = filmRate*factor
            
            if actor in actors:
                actors[actor]['size'] = actors[actor]['size'] + 1
                actors[actor]['total'] = actors[actor]['total'] + (weightRate)
                actors[actor]['avg'] = actors[actor]['total'] / actors[actor]['size']
            else:
                actors[actor] = {'size': 1, 'total': weightRate, 'avg': weightRate/1}

    for actor in actors:
        if actors[actor]['size'] > 2:
            print(actor, ' - ', actors[actor])

    print("---------------------")
    
    return actors

#gets crew ratings
def getCrew(ratings):
    weight = 0
    # 0 for standard weights
    # increase for dramatic weights
    crew = {}
    
    for movie in ratings:
        filmRate = ratings[movie]['rating']
        filmCrew = ratings[movie]['film_data']['crew']
        filmCrew = filmCrew[:int(len(filmCrew)/2)]
        
        if filmRate == 'bookmark':
            filmRate = 7

        elif filmRate == 'ignore':
            filmRate = 0

        for i, crewint in enumerate(filmCrew):
            member = crewint['name']
            factor = ((len(filmCrew) - i - 1)*weight *0.1) + 1

            weightRate = filmRate*factor
            
            if member in crew:
                crew[member]['size'] = crew[member]['size'] + 1
                crew[member]['total'] = crew[member]['total'] + (weightRate)
                crew[member]['avg'] = crew[member]['total'] / crew[member]['size']
            else:
                crew[member] = {'size': 1, 'total': weightRate, 'avg': weightRate/1}

    for member in crew:
        if crew[member]['size'] > 2:
            print(member, ' - ', crew[member])

    print("---------------------")
    
    return crew

#gets keywords ratings
def getKeywords(ratings):
    weight = 0
    # 0 for standard weights
    # increase for dramatic weights
    keywords = {}
    
    for movie in ratings:
        filmRate = ratings[movie]['rating']

        if 'keywords' not in ratings[movie]['film_data']: continue

        filmKey = ratings[movie]['film_data']['keywords']
        
        if filmRate == 'bookmark':
            filmRate = 7

        elif filmRate == 'ignore':
            filmRate = 0

        for i, keywordsint in enumerate(filmKey):
            member = keywordsint['name']
            factor = ((len(filmKey) - i - 1)*weight *0.1) + 1

            weightRate = filmRate*factor
            
            if member in keywords:
                keywords[member]['size'] = keywords[member]['size'] + 1
                keywords[member]['total'] = keywords[member]['total'] + (weightRate)
                keywords[member]['avg'] = keywords[member]['total'] / keywords[member]['size']
            else:
                keywords[member] = {'size': 1, 'total': weightRate, 'avg': weightRate/1}

    for member in keywords:
        if keywords[member]['size'] > 2:
            print(member, ' - ', keywords[member])

    print("---------------------")
    
    return keywords

#gets keywords ratings
def getYears(ratings):
    weight = 0
    # 0 for standard weights
    # increase for dramatic weights
    years = {}
    
    for movie in ratings:
        filmRate = ratings[movie]['rating']

        if 'keywords' not in ratings[movie]['film_data']: continue

        filmYear = ratings[movie]['film_data']['release_date']
        filmYear = datetime.strptime(filmYear, "%Y-%m-%d").year
        
        if filmRate == 'bookmark':
            filmRate = 7

        elif filmRate == 'ignore':
            filmRate = 0
            
        if filmYear in years:
            years[filmYear]['size'] = years[filmYear]['size'] + 1
            years[filmYear]['total'] = years[filmYear]['total'] + filmRate
            years[filmYear]['avg'] = years[filmYear]['total'] / years[filmYear]['size']
        else:
            years[filmYear] = {'size': 1, 'total': filmRate, 'avg': filmRate/1}

    for filmYear in years:
        if years[filmYear]['size'] > 2:
            print(filmYear, ' - ', years[filmYear])

    print("---------------------")
    years = fillin(years)
    return years

#gets genre ratings
def getGen(ratings):
    weight = 0
    # 0 for standard weights
    # increase for dramatic weights
    genres = {}
    
    for movie in ratings:
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

    for genre in genres:
        if genres[genre]['size'] > 2:
            print(genre, ' - ', genres[genre])

    print("---------------------")
    return genres

def fillin(years):

    for year in range(1900, 2030):
        if year not in years:
            years[year] = {'size': 0, 'total': 0, 'avg': None}

    #Linkear interpolation
    gaps = [year for year, value in years.items() if value['avg'] is None]
    
    for year in gaps:

        prev = None
        next = None
        for y, v in sorted(years.items()):
            if y < year and v['avg'] is not None:
                prev = y
            elif y > year and v['avg'] is not None:
                next = y
                break

        #skip
        if prev is None or next is None:
            continue

        #linear int
        #https://www.geeksforgeeks.org/wp-content/ql-cache/quicklatex.com-1fdaccf93d8bcbf6128f0a169911ba1a_l3.svg
        years[year]['avg'] = years[prev]['avg'] + (years[next]['avg'] - years[prev]['avg']) / (next - prev) * (year - prev)

    for year in years:
        if years[year]['avg'] == None: years[year]['avg'] = 0
        print(year, ' ', years[year])
    return years

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