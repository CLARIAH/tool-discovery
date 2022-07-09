import json
from flask import Flask, jsonify, request

def filenamify_url(url_str):
    return_val = url_str
    return return_val.replace('http://','').replace('https://','').replace('/','!').replace('#','_').replace('?','_')


app=Flask(__name__)

@app.route("/rest/",methods=['GET','POST'])
def index():
    if request.method=='GET': 
        return jsonify({"msg":"Hello Flask!"})
    if request.method=='POST': 
        #content_type = request.headers.get('Content-Type')
        #if (content_type == 'application/json'):  OR 'text/plain' 
        #data = response.json() OR data = request.get_json()
        data=json.loads(request.data)
        print("Got json data from POST " + str(data))
        #tested with  curl -XPOST -H "Content-Type: application/json" -d@codemeta.json http://10.160.0.24/rest/
        #codeRepository or @id values
        value=data['codeRepository'] + ".codemeta.json"
        filename=filenamify_url(value)
        filepath="/tmp/out/" + filename
        print("cleaned filename: " + filename)
        with open(filepath, 'w', encoding='latin-1') as my_file:
            json.dump(data, my_file)
        #subprocess.Popen(['sh', '/usr/bin/event-harvest.sh']).wait()
        return jsonify(data)

if __name__ == '__main__':
    print ("Running Python app.py")
    from waitress import serve
    serve(app,host='127.0.0.1',port=5555)
