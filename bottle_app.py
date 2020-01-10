from bottle import *
from bottle.ext import sqlite
from os import path

# File dir
ROOT = path.dirname(path.realpath(__file__))

app = Bottle()
plugin = sqlite.Plugin(dbfile=path.join(ROOT,'points.db'))
app.install(plugin)


@app.route('/')
@view('index.tpl')
def map():
    context = {'title': "Où doit aller l'hélico ?"}
    return context


@app.route('/static/<filename:path>')
def server_static(filename):
    return static_file(filename, root='.')


@app.route('/sendPoint', method='GET')
def getPoint(db):
    # Extraction des paramètres
    x = request.params.get('x', 0.0, type=float)
    y = request.params.get('y', 0.0, type=float)
    # Insertion DB
    #db.execute('INSERT INTO point(date, x, y) VALUES (CURRENT_TIMESTAMP,?,?)', (x,y))
    db.execute('INSERT INTO point(date, x, y) SELECT CURRENT_TIMESTAMP,?,? WHERE NOT EXISTS(SELECT 1 FROM point WHERE x=? AND y=?)', (x,y)*2)


@app.route('/getPoints', method='GET')
def sendPoint(db):
    data = request.json
    fr = request.params.get('from', type=str)


    # Requête
    points = db.execute('SELECT x,y FROM point WHERE date >= ?', (fr,))
    # Renvoit valeurs
    response.content_type = 'application/json'
    t = [{'x':i['x'], 'y':i['y']} for i in points.fetchall()]
    return dict(data=t)

if __name__ == '__main__':
    app.run()