from flask import Flask

app = Flask(__name__)
app.config.from_object('shiken_dokei.config')


import shiken_dokei.views