from flask import request, redirect, url_for, render_template, flash, session
from shiken_dokei import app



@app.route('/')
def start_page():
    return render_template('entries/index.html')

@app.route('/setting', methods=['GET', 'POST'])
def setting_page():
    if request.method == 'POST':
        kamoku = request.form['radio_input']
        # 1つのvalueに複数の情報を持たせるため、区切り文字を使っていた。それを分割してlistに
        kamoku_jikoku = kamoku.split('_')
        set_time1 = request.form['time1']
        set_time2 = request.form['time2']

        return render_template('entries/setting.html', 
                    time1=set_time1, time2=set_time2, input_from_python=kamoku_jikoku)
    else:
        return render_template('entries/setting.html', input_from_python="aaa")