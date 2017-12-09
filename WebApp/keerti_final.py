
import os
import pickle
import copy
import datetime as dt
from datetime import timedelta

import pandas as pd
from flask import Flask
import dash
from dash.dependencies import Input, Output, State
import dash_core_components as dcc
import dash_html_components as html
import pandas as pd
import numpy as np
from pandas.tseries.holiday import USFederalHolidayCalendar as calendar
from sklearn.externals import joblib
# from datetime import datetime as dt

df = pd.read_csv('../clean_data/FinalData_for_Models.csv')
loaded_model = joblib.load("../model_stack_noxgb.pkl")

# Multi-dropdown options
# from controls import COUNTIES, WELL_STATUSES, WELL_TYPES, WELL_COLORS
app = dash.Dash()  # noqa: E501
app.css.append_css({'external_url': 'https://cdn.rawgit.com/plotly/dash-app-stylesheets/2d266c578d2a6e8850ebce48fdb52759b2aef506/stylesheet-oil-and-gas.css'})  # noqa: E501


# points = pickle.load(open("data/points.pkl", "rb"))


# Create global chart template
mapbox_access_token = 'pk.eyJ1IjoiamFja2x1byIsImEiOiJjajNlcnh3MzEwMHZtMzNueGw3NWw5ZXF5In0.fk8k06T96Ml9CLGgKmk81w'  # noqa: E501

layout = dict(
    autosize=True,
    height=500,
    font=dict(color='#CCCCCC'),
    titlefont=dict(color='#CCCCCC', size='14'),
    margin=dict(
        l=35,
        r=35,
        b=35,
        t=45
    ),
    hovermode="closest",
    plot_bgcolor="#191A1A",
    paper_bgcolor="#020202",
    legend=dict(font=dict(size=10), orientation='h'),
    title='Satellite Overview',
    mapbox=dict(
        accesstoken=mapbox_access_token,
        style="dark",
        center=dict(
            lon=-78.05,
            lat=42.54
        ),
        zoom=7,
    )
)


# In[]:
# Create app layout
app.layout = html.Div(
    [
        html.Div(
            [
                html.H1(
                    'Estimating Taxi Demand at LaGaurdia Airport',
                    className='ten columns',
                ),
                # html.Img(
                #     src="https://s3-us-west-1.amazonaws.com/plotly-tutorials/logo/new-branding/dash-logo-by-plotly-stripe.png",
                #     className='one columns',
                #     style={
                #         'height': '100',
                #         'width': '225',
                #         'float': 'right',
                #         'position': 'relative',
                #     },
                # ),
            ],
            className='row', style={'margin-bottom':'20px', 'color' : '#8A2BE2'}
        ),
        html.Div(
            [
                # html.H5(
                #     '',
                #     id='well_text',
                #     className='two columns'
                # ),

                html.H6('Date', className='one columns'),
                html.Div([dcc.DatePickerSingle(
                id='my-date-picker-single',
                min_date_allowed=dt.datetime(2014, 1, 1),
                max_date_allowed=dt.datetime(2020, 12, 31),
                initial_visible_month=dt.datetime(2017, 12, 11),
                date=dt.datetime(2017, 12, 11)
                )], className='two columns'),


                # html.H5(
                #     '',
                #     id='production_text',
                #     className='eight columns',
                #     style={'text-align': 'center'}
                # ),
                # html.H5(
                #     '',
                #     id='year_text',
                #     className='two columns',
                #     style={'text-align': 'right'}
                # ),
            ],
            className='row'
        ),
        html.Div(
            [
                html.P('Select Hour:'),  # noqa: E501
                dcc.Slider(
                    id='hour',
                    min=0,
                    max=23,
                    marks={i: '{}'.format(i) for i in range(0, 24)},
                    value=10                
                ),
            ], className='six columns',
            style={'margin-top': '20', 'margin-bottom': '30px'}
        ),
        html.Div(
            [
                html.Div(
                    [
                        html.P('Filter by Precipitation:'),
                        dcc.Dropdown(
                            id='precipitation',
                            options=[
                                {'label': 'None', 'value': 0},
                                {'label': 'Light', 'value': 0.04},
                                {'label': 'Medium', 'value': 0.13},
                                {'label': 'Heavy', 'value': 0.35}
                            ],
                            value=0
                            # labelStyle={'display': 'inline-block'}
                        ),
                        # dcc.Dropdown(
                        #     id='well_statuses',
                        #     options={},
                        #     multi=True,
                        #     value=[]
                        # ),
                        # dcc.Checklist(
                        #     id='lock_selector',
                        #     options=[
                        #         {'label': 'Lock camera', 'value': 'locked'}
                        #     ],
                        #     values=[],
                        # )
                    ],
                    className='five columns', style={'margin-left':'600px', 'margin-top': '-90px', 'display':'block'}
                ),
                html.Div(
                    [
                        html.P('Input Temperature (deg F):'),
                        dcc.Input(id='temp', value=70, type='int'),
                        # dcc.Dropdown(
                        #     id='well_types',
                        #     options={},
                        #     multi=True,
                        #     value=list([1,2,3]),
                        # ),
                    ],
                    className='six columns'
                ),
            ],
            className='row', style= {'margin-top': '110px'}
        ),

                html.Div(
                    [
                        html.P('Filter by Weather Category:'),
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
                        )
                        # dcc.Dropdown(
                        #     id='well_statuses',
                        #     options={},
                        #     multi=True,
                        #     value=[]
                        # ),
                        # dcc.Checklist(
                        #     id='lock_selector',
                        #     options=[
                        #         {'label': 'Lock camera', 'value': 'locked'}
                        #     ],
                        #     values=[],
                        # )
                    ],
                    className='five columns', style={'margin-left':'600px', 'margin-top': '-65px', 'display':'block', 'margin-bottom': '40px'}
                ),
        html.Div(
            [   
                html.P('Number of Pickups', style={'font-size': '2.0rem', 'margin-bottom':'-30px'}),
                html.Div(id='Prediction',
                    className='three columns',
                    style={'margin-top': '20', 'font-size': '6.0rem', 'color': '#003406'}

                ),
                html.Div(
                    [
                        dcc.Graph(id='predict_graph')
                    ],
                    className='nine columns',
                    style={'margin-top': '20'}
                ),   
            ],
            className='row'
        ),
        html.Div(
            [
                html.Div(
                    [
                        dcc.Graph(id='count_graph')
                    ],
                    className='four columns',
                    style={'margin-top': '10'}
                ),
                html.Div(
                    [
                        dcc.Graph(id='pie_graph')
                    ],
                    className='four columns',
                    style={'margin-top': '10'}
                ),
                html.Div(
                    [
                        dcc.Graph(id='aggregate_graph')
                    ],
                    className='four columns',
                    style={'margin-top': '10'}
                ),
            ],
            className='row'
        ),
    ],
    className='ten columns offset-by-one'
)


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

    return ('{}'.format(int(loaded_model.predict(feature_vect))))



# @app.callback(
#     dash.dependencies.Output('graph_results', 'figure'),
#     [dash.dependencies.Input('my-date-picker-single', 'date'),
#      dash.dependencies.Input('hour', 'value')])
# def update_graph(date, hour):
    
#     new_date = pd.to_datetime(date, format='%Y-%m-%d')
#     month = new_date.month
#     day = new_date.dayofweek
    
#     actual = df.loc[(df.Month == month) & (df.Day == day) & (df.Hour == hour), ['Unnamed: 0', 'num_pickups']]    
#     actual.iloc[:,0] = pd.to_datetime(actual.iloc[:,0]).apply(lambda x: x.date())    
    
#     return  {'data': [
#                 {'x': str(actual.iloc[:,0]), 'y': actual['num_pickups'], 'type': 'bar', 'name': 'actual'}]}
    


    
@app.callback(
    dash.dependencies.Output('predict_graph', 'figure'),
    [dash.dependencies.Input('my-date-picker-single', 'date'),
     dash.dependencies.Input('precipitation', 'value'),
     dash.dependencies.Input('weather', 'value'),
     dash.dependencies.Input('temp', 'value'),
     dash.dependencies.Input('hour', 'value')])

def update_prediction_graph(date, precipitation, weather, temp, hour):
    layout_pred = copy.deepcopy(layout)

    new_date = pd.to_datetime(date, format='%Y-%m-%d')
    
    axis_hours = ["{} hour".format((hour+i)%23) for i in range(7) ]
    print(axis_hours)

    prediction_list = []
    my_hours = np.zeros(7)
    
    #take each of the 6 hours
    for i in range(7):
        my_hours[i] = hour + i
        #check end of day edge case
        if my_hours[i] > 23:
            my_hours[i] = my_hours[i] - 24
            prediction_list.append(update_featurevect(new_date + pd.DateOffset(1), precipitation, weather, temp, my_hours[i]))
        else:
            prediction_list.append(update_featurevect(new_date, precipitation, weather, temp, my_hours[i]))

    data= [dict(x=axis_hours, y=prediction_list, type= 'line')]

    layout_pred['title'] = 'Estimated Number of Taxi Pickups for Next 6 Hours'
    # layout_pred['dragmode'] = 'select'
    layout_pred['showlegend'] = False
    # layout_pred['xaxis'] = 'Hours'
    layout_pred['yaxis'] = dict(range=[0,1300])

    figure = dict(data=data, layout=layout_pred)

    return figure
    

def update_featurevect(date, precipitation, weather, temp, hour):
    new_date = date
    
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
    return int(loaded_model.predict(feature_vect))
    
    
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

if __name__ == '__main__':
    app.server.run(debug=True, threaded=True)
