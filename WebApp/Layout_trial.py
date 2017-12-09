
# coding: utf-8

# In[1]:

import dash
import dash_html_components as html
import dash_core_components as dcc
from datetime import datetime as dt

# layout = dict(
#     autosize=True,
#     height=50,
#     font=dict(color='#DC143C'),
#     position = 'relative',
#     titlefont=dict(color='#DC143C', size='25'),
#     # margin=dict(
#     #     l=35,
#     #     r=35,
#     #     b=35,
#     #     t=45
#     # ),
#     margin = 'auto', 
#     hovermode="closest",
#     plot_bgcolor="#191A1A",
#     paper_bgcolor="#020202",
#     legend=dict(font=dict(size=200), orientation='h'),
#     title='Satellite Overview',
#     # mapbox=dict(
#     #     accesstoken=mapbox_access_token,
#     #     style="dark",
#     #     center=dict(
#     #         lon=-78.05,
#     #         lat=42.54
#     #     ),
#     #     zoom=7,
#     # )
# )

app = dash.Dash()

# app.css.append_css({"external_url": 'https://codepen.io/chriddyp/pen/bWLwgP.css'})


app.layout = html.Div([html.Div([
        
     # html.Img(src="https://cdn.newsday.com/polopoly_fs/1.12036027.1468362303!/httpImage/image.jpeg_gen/derivatives/landscape_1280/image.jpeg",
     #            style={
     #                'height': '100px',
     #                'float': 'right',
     #                'position': 'relative',
     #                'bottom': '40px',
     #                'left': '100px'
     #            },
     #            ),
    

    html.H1('Estimating Taxi Demand at LaGaurdia Aiport'
        ,style={
                    # 'position': 'relative',
                    # 'align' : 'center',
                    # 'top': '0px',
                    # 'left': '10px',
                    'font-family': 'Dosis',
                    # 'display': 'inline',
                    'font-size': '3.0rem',
                    'color': '#8A2BE2',
                    'margin': 'auto',
                    'margin-left':'40px'
                }
                )]),


    html.Div([html.Div([html.Label('Date', style={'position': 'relative',
                    # 'align' : 'center',
                    'top': '5px',
                    # 'left': '10px',
                    'font-family': 'Dosis',
                    'display': 'inline',
                    'font-size': '1.5rem',
                    'color': '#000000',
                    'margin': 'auto'
                    })]),
    dcc.DatePickerSingle(
        id='my-date-picker-single',
        min_date_allowed=dt(2014, 1, 1),
        max_date_allowed=dt(2020, 12, 12),
        initial_visible_month=dt(2017, 12, 11),
        date=dt(2017, 12, 11)
    ),
    html.Div(id='my-date-picker-single', style={'position': 'relative',
                    # 'align' : 'center',
                    # 'top': '5px',
                    # # 'left': '10px',
                    # 'font-family': 'Dosis',
                    # # 'display': 'inline',
                    # 'font-size': '1.5rem',
                    # 'color': '#000000',
                    # 'margin': 'auto',
                    'margin-left': '100px', 'size':'20px', 'margin-bottom':'20px'}),
                     
    html.Label('Hour of Day', style={'position': 'relative',
                    # 'align' : 'center',
                    'top': '5px',
                    # 'left': '10px',
                    'bottom':'100px',
                    'font-family': 'Dosis',
                    'display': 'inline',
                    'font-size': '1.5rem',
                    'color': '#000000',
                    # 'margin': 'auto',
                    'margin-top':'100px'}),
    dcc.Slider(
        id='slider_hour',
        min=0,
        max=23,
        marks={i: '1'.format(i) if i == 1 else str(i) for i in range(0, 24)},
        value=10
    ),
    html.Div(id='slider_hour', style={'max-width':'50px','margin-right':'1000px'})
    ], style={'margin-top':'40px', 'margin-bottom':'40px', 'position':'relative'}),    
    
    html.Label('Precipitation', style={'position': 'relative',
                    # 'align' : 'center',
                    # 'top': '5px',
                    # 'float':'left',
                    'font-family': 'Dosis',
                    'display': 'inline',
                    'font-size': '1.5rem',
                    'color': '#000000',
                    'margin': 'auto'}),
    html.Div([dcc.Dropdown(
        options=[
            {'label': 'None', 'value': 0},
            {'label': 'Light', 'value': 0.2},
            {'label': 'Medium', 'value': 0.5},
            {'label': 'Heavy', 'value': 0.8}
        ],
        value='MTL'
    )], style={'position':'relative', 'margin-bottom':'30px'}),

    html.Label('Weather Description', style={'position': 'relative',
                    # 'align' : 'center',
                    # 'top': '5px',
                    # 'float':'left',
                    'font-family': 'Dosis',
                    'display': 'inline',
                    'font-size': '1.5rem',
                    'color': '#000000',
                    'margin': 'auto'}),
    html.Div([dcc.Dropdown(
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
    )], style={'margin-bottom':'30px'}),

    html.Label('Temperature (deg F)', style={'position': 'relative',
                    # 'align' : 'center',
                    # 'top': '5px',
                    # 'float':'left',
                    'font-family': 'Dosis',
                    # 'display': 'inline',
                    'font-size': '1.5rem',
                    'color': '#000000',
                    'margin': 'auto'}),
    html.Div([dcc.Input(value=70, type='int')], style={'height': '100px', 'width':'100px'}),         
        
], style={'columnCount': 3})


if __name__ == '__main__':
    app.run_server(debug=True)




