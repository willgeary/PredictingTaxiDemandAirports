
# coding: utf-8

# In[1]:

import dash
import dash_html_components as html
import dash_core_components as dcc
from datetime import datetime as dt
import pandas as pd
import numpy as np
from pandas.tseries.holiday import USFederalHolidayCalendar as calendar
from sklearn.externals import joblib
# get_ipython().magic(u'matplotlib inline')


# In[2]:

df = pd.read_csv('../clean_data/FinalData_for_Models.csv')


# In[3]:

loaded_model = joblib.load("../../model_stack_noxgb.pkl")


# In[4]:

# from IPython import display
# def show_app(app,  # type: dash.Dash
#              port=9999,
#              width=700,
#              height=350,
#              offline=True,
#              style=True,
#              **dash_flask_kwargs):
#     """
#     Run the application inside a Jupyter notebook and show an iframe with it
#     :param app:
#     :param port:
#     :param width:
#     :param height:
#     :param offline:
#     :return:
#     """
#     url = 'http://localhost:%d' % port
#     iframe = '<iframe src="{url}" width={width} height={height}></iframe>'.format(url=url,
#                                                                                   width=width,
#                                                                                   height=height)
#     display.display_html(iframe, raw=True)
#     if offline:
#         app.css.config.serve_locally = True
#         app.scripts.config.serve_locally = True
#     if style:
#         external_css = ["https://fonts.googleapis.com/css?family=Raleway:400,300,600",
#                         "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css",
#                         "http://getbootstrap.com/dist/css/bootstrap.min.css", ]

#         for css in external_css:
#             app.css.append_css({"external_url": css})

#         external_js = ["https://code.jquery.com/jquery-3.2.1.min.js",
#                        "https://cdn.rawgit.com/plotly/dash-app-stylesheets/a3401de132a6d0b652ba11548736b1d1e80aa10d/dash-goldman-sachs-report-js.js",
#                        "http://getbootstrap.com/dist/js/bootstrap.min.js"]

#         for js in external_js:
#             app.scripts.append_script({"external_url": js})

#     return app.run_server(debug=False,  # needs to be false in Jupyter
#                           port=port,
#                           **dash_flask_kwargs)


# In[5]:

app = dash.Dash()
app.css.append_css({"external_url": "https://codepen.io/chriddyp/pen/bWLwgP.css"})
app.layout = html.Div([
        
    html.H1('Estimating Taxi Demand at LaGaurdia Aiport'
        ,style={
                    # 'position': 'relative',
                    # 'align' : 'center',
                    # 'top': '0px',
                    # 'left': '10px',
                    # 'font-family': 'Dosis',
                    # 'display': 'inline',
                    'font-size': '4.5rem',
                    'color': '#8A2BE2',
                    # 'margin': 'auto',
                    'margin-left':'140px'
                }
                ),
    html.Div([html.Div([html.Label('Date'
        , style={
                    # 'position': 'relative',
                    # 'align' : 'center',
                    # 'top': '0px',
                    # 'left': '10px',
                    # 'font-family': 'Dosis',
                    'display': 'block',
                    'font-size': '2.5rem'
                    # 'color': '#000000',
                    # 'margin': 'auto'
                    # 'margin-left':'40px'
                }
                )],className='two columns', style={'margin-left': '100px'}),
    html.Div([dcc.DatePickerSingle(
        id='my-date-picker-single',
        min_date_allowed=dt(2014, 1, 1),
        max_date_allowed=dt(2020, 12, 31),
        initial_visible_month=dt(2017, 12, 11),
        date=dt(2017, 12, 11)
    )], className='two columns', style={'display':'block', 'margin-left':'0px'}),
    html.Div(style={'margin-bottom':'20px'}),    
    

    html.Div([html.Label('Hour of Day'
        # , style={
        #             # 'position': 'relative',
        #             # 'align' : 'center',
        #             # 'top': '0px',
        #             # 'left': '10px',
        #             # 'font-family': 'Dosis',
        #             # 'display': 'block',
        #             'font-size': '1.5rem',
        #             # 'color': '#000000',
        #             # 'margin': 'auto'
        #             # 'margin-left':'40px'
        #         }
                )], className='two columns', style = {'font-size': '2.5rem'}),
    html.Div([dcc.Slider(
        id='hour',
        min=0,
        max=23,
        marks={i: '{}'.format(i) if i == 1 else str(i) for i in range(0, 24)},
        value=10
        
        )], className='four columns', style={'margin-right': '100px'}),
    html.Div(style={'margin-bottom':'30px'})],className='row'),
    html.Label('Precipitation', style={'position': 'relative',
                    # 'align' : 'center',
                    # 'top': '5px',
                    # 'float':'left',
                    'font-family': 'Dosis',
                    'display': 'inline',
                    'font-size': '1.5rem',
                    'color': '#000000',
                    'margin': 'auto'}),
    dcc.Dropdown(
        id='precipitation',
        options=[
            {'label': 'None', 'value': 0},
            {'label': 'Light', 'value': 0.04},
            {'label': 'Medium', 'value': 0.13},
            {'label': 'Heavy', 'value': 0.35}
        ],
        value=0
    ),
    html.Div(style={'margin-bottom':'30px'}),

    html.Label('Weather Description',style={'position': 'relative',
                    # 'align' : 'center',
                    # 'top': '5px',
                    # 'float':'left',
                    'font-family': 'Dosis',
                    'display': 'inline',
                    'font-size': '1.5rem',
                    'color': '#000000',
                    'margin': 'auto'}),
    dcc.Dropdown(
        id='weather',
        options=[
            {'label': 'Clear', 'value': 'clear'},
            {'label': 'Clouds', 'value': 'clouds'},
            {'label': 'Fog', 'value': 'fog'},
            {'label': 'Rain', 'value': 'rain'},
            {'label': 'Snow', 'value': 'snow'},
            {'label': 'Thunderstorm', 'value': 'thunderstorm'},
        ],
        value=['clear'],
        multi=True
    ),
    html.Div(style={'margin-bottom':'30px'}),

    html.Label('Temperature (deg F)',style={'position': 'relative',
                    # 'align' : 'center',
                    # 'top': '5px',
                    # 'float':'left',
                    'font-family': 'Dosis',
                    'display': 'block',
                    'font-size': '1.5rem',
                    'color': '#000000',
                    'margin': 'auto'}),
    dcc.Input(id='temp', value=70, type='int'),

    html.Div(style={'margin-bottom':'30px'}),
            
        
    html.Div(id='Prediction',style={'position': 'relative',
                    # 'align' : 'center',
                    # 'top': '5px',
                    # 'float':'left',
                    'font-family': 'Dosis',
                    'display': 'block',
                    'font-size': '1.5rem',
                    'color': '#000000',
                    'margin': 'auto'}),
        
    dcc.Graph(id='graph_results')


        
])


@app.callback(
    dash.dependencies.Output('Prediction', 'children'),
    [dash.dependencies.Input('my-date-picker-single', 'date'),
     dash.dependencies.Input('precipitation', 'value'),
     dash.dependencies.Input('weather', 'value'),
     dash.dependencies.Input('temp', 'value'),
     dash.dependencies.Input('hour', 'value')])

def update_prediction(date, precipitation, weather, temp, hour):

    new_date = pd.to_datetime(date, format='%Y-%m-%d')
    month = new_date.month
    #array
    months = month_format(month)
    
    day = new_date.dayofweek
    #array
    days = day_format(day)
    
    #array
    weather_dummies = weather_format(weather)
    
    #Converting Fahrenheit to Python
    if temp == '':
        temp = 0.0
    
    temp_K = np.array([(float(temp) + 459.67)*(5.0/9.0)])
    
    #array
    hours = hour_format(hour)
    
    hol = is_holiday(date)
    
    #Getting average humidity at give month, day, hour
    humidity = np.array([df.loc[(df.Month == month) & (df.Day == day) & (df.Hour == hour), 'humidity'].mean()])
    wind_speed = np.array([df.loc[(df.Month == month) & (df.Day == day) & (df.Hour == hour), 'wind_speed'].mean()])
    
    #Getting average passengers and delays at given day, hour, holiday
    flight_info = df.loc[(df.Hour == hour) & (df.Day == day) & (df.holiday == hol), ['Passengers', 'Avg_Delay_Arriving', 'Cancelled_Departing_Flights']].mean()
    passengers, delays, cancellations = flight_info.values
    
    #Taking edge cases in case day = 0 or hour = 0 when solving prev hour info
    last_day = day
    last_2day = day
    
    last_hour = hour - 1
    last_2hour = hour - 2
    
    if hour == 0:
        last_hour = 23
        last_2hour = 22
        if day == 0:
            last_day = 6
            last_2day = 6
        else:
            last_day = day-1
            last_2day = day-1
    
    if hour == 1:
        last_2hour = 23
        if day == 0:
            last_2day = 6
        else:
            last_2day = day-1
        
    
    #Getting previous hours passenger info at given day, hour, holiday
    prev_hour_pass = np.array([df.loc[(df.Hour == last_hour) & (df.Day == last_day) & (df.holiday == hol), 'Passengers'].mean()])
    prev_2hour_pass = np.array([df.loc[(df.Hour == last_2hour) & (df.Day == last_2day) & (df.holiday == hol), 'Passengers'].mean()])
    
    
    hol_array = np.array([int(hol)])
    
    precipitation = np.array([precipitation])
    
    #Putting it in the right order
    feature_vect = np.concatenate((temp_K, humidity, wind_speed, np.array([passengers]), hol_array, precipitation, 
                                  np.array([delays]), np.array([cancellations]), weather_dummies, prev_hour_pass, 
                                  prev_2hour_pass, months, hours, days))
    #reshaping to be 2D
    feature_vect = feature_vect.reshape(1, len(feature_vect))

    return ('Estimated Passengers Arrived: {0} Predicted Number of Pickups: {1}'.format(
                                int(passengers),
                                int(loaded_model.predict(feature_vect))))




@app.callback(
    dash.dependencies.Output('graph_results', 'figure'),
    [dash.dependencies.Input('my-date-picker-single', 'date'),
     dash.dependencies.Input('hour', 'value')])
def update_graph(date, hour):
    
    new_date = pd.to_datetime(date, format='%Y-%m-%d')
    month = new_date.month
    day = new_date.dayofweek
    
    actual = df.loc[(df.Month == month) & (df.Day == day) & (df.Hour == hour), ['Unnamed: 0', 'num_pickups']]    
    actual.iloc[:,0] = pd.to_datetime(actual.iloc[:,0]).apply(lambda x: x.date())    
    
    return  {'data': [
                {'x': str(actual.iloc[:,0]), 'y': actual['num_pickups'], 'type': 'bar', 'name': 'actual'}]}
    


# In[6]:

def day_format(day):
    days = np.zeros(7)
    days[day] = 1
    return days


# In[7]:

def month_format(month):
    months = np.zeros(12)
    months[month-1] = 1
    return months


# In[8]:

def weather_format(weather):
    array = np.zeros(6)
    if 'clear' in weather:
        array[0] = 1
    if 'clouds' in weather:
        array[1] = 1
    if 'fog' in weather:
        array[2] = 1
    if 'rain' in weather:
        array[3] = 1
    if 'snow' in weather:
        array[4] = 1
    if 'thunderstorm' in weather:
        array[5] = 1
    return array
        
#clear, clouds, fog, rain, snow, thunderstorm


# In[9]:

# def hour_format(hour):
#     hours = np.zeros(24)
#     hours[hour] = 1
#     return hours

#new format
def hour_format(hour):
    hours = np.zeros(4)
    if hour < 7:
        hours[0] = 1
    elif hour < 13:
        hours[1] = 1
    elif hour < 19:
        hours[2] = 1
    else:
        hours[3] = 1
    return hours


# In[10]:

def is_holiday(date):
    dr = pd.date_range(pd.Timestamp('2014-01-01'), pd.Timestamp('2020-12-31'))
    cal = calendar()
    holidays = cal.holidays(start=dr.min(), end=dr.max())

    return date in holidays


# In[ ]:

# show_app(app)
if __name__ == '__main__':
    app.run_server(debug=True)

