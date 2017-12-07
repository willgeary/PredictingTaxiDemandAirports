
# coding: utf-8

# ### Import Statements

# In[44]:


from sklearn.linear_model import Ridge, LinearRegression, Lasso, RidgeCV, LassoCV
from sklearn.preprocessing import StandardScaler, RobustScaler, MinMaxScaler, Normalizer
from sklearn.model_selection import cross_val_score, TimeSeriesSplit
from sklearn.preprocessing import PolynomialFeatures
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV
from sklearn.pipeline import make_pipeline
from sklearn.feature_selection import VarianceThreshold, RFE, RFECV, SelectFromModel, SelectPercentile, mutual_info_regression
from sklearn.ensemble import RandomForestRegressor, BaggingRegressor, GradientBoostingRegressor, AdaBoostRegressor
from sklearn.neighbors import KNeighborsRegressor
from sklearn.svm import SVR
from mlxtend.feature_selection import ColumnSelector, SequentialFeatureSelector
import pandas as pd
import numpy as np
#from xgboost import XGBRegressor
from sklearn.externals import joblib
#import matplotlib.pyplot as plt
from sklearn.utils import shuffle
from sklearn.model_selection import train_test_split
from xgboost import XGBRegressor
#import seaborn as sns
from sklearn.tree import export_graphviz

#sns.set_style("darkgrid")


# In[2]:


pd.set_option('display.max_columns', 500)
pd.set_option('display.max_rows', 500)


# ### Read the Data

# In[3]:


data = pd.read_csv("../clean_data/FinalData_for_Models.csv")


# In[4]:


data.rename(columns={'Unnamed: 0':'pickup_time'}, inplace=True)


# In[5]:


data.head()


# In[6]:


## ignoring the missing data values in 2016
data = data.loc[data.missing_dt == False, :]
data.drop("missing_dt", axis=1, inplace=True)


# In[7]:


data.shape


# ### Creating Dummies for Weather Data

# In[8]:


## for weather main
data_wm_dummies = data['weather_main'].str.split(",").str.join("*").str.get_dummies(sep='*')


# In[9]:


## for weather description
data_wd_dummies = data['weather_description'].str.split(",").str.join("*").str.get_dummies(sep='*')


# In[10]:


data.drop(["weather_main", "weather_description"], axis=1, inplace=True)


# In[11]:


data = pd.concat([data, data_wm_dummies], axis=1)


# In[12]:


data.shape


# In[13]:


data.head()


# ** Remark : We can choose to only include weather main categories or weather description also alongwith <br> TRY BOTH OF THEM FOR MODELS **

# ### Modifying Boolean Data Columns (Holiday)

# In[14]:


data['holiday'] = data.holiday.astype(int)


# In[15]:


data.head()


# ### Time Feature

# In[16]:


data.rename(columns={'Hour':'HourOfDay'}, inplace=True)
data.rename(columns={'Day':'DayOfWeek'}, inplace=True)


# In[17]:


data.head(2)


# In[18]:


data.shape


# ### Quantile Cuts for Hour of Day to divide Hour of Days into 4 Main 6 Hour Categories

# In[19]:


data['HourOfDay'] = pd.qcut(data['HourOfDay'], 4)


# In[20]:


data.dtypes


# In[21]:


data.head()


# ### Drop the Pickup Time and Number of Passengers

# In[22]:


data.drop([
        "pickup_time",
        "num_passengers"], axis=1, inplace=True)


# ### Dropping cancelled arriving flights as they should have no influence in pickups at LGA

# In[23]:


## as they will probably have no predictive value
data.drop(['Cancelled_Arriving_Flights'], axis=1, inplace=True)


# In[24]:


data.drop(['Avg_Delay_Departing'], axis=1, inplace=True)


# ### Last 2 hour Passengers (1 Hour Ago and 2 Hours Ago)

# In[25]:


data['Prev_hour_Passengers'] = data['Passengers'].shift(1)
data['Prev_2hour_Passengers'] = data['Passengers'].shift(2)


# In[26]:


data.Prev_hour_Passengers = data.Prev_hour_Passengers.fillna(method='bfill')
data.Prev_2hour_Passengers = data.Prev_2hour_Passengers.fillna(method='bfill')


# ### Dropping Temp_Mix and Temp_Max as we already have Temp

# In[27]:


data.drop(['temp_min', 'temp_max'], axis=1, inplace=True)


# ### Converting Month and Day of Week to Categorical Data

# In[28]:


data.Month = pd.Categorical(data.Month)
data.DayOfWeek = pd.Categorical(data.DayOfWeek)


# In[29]:


data = pd.get_dummies(data)


# In[30]:


data.head()


# In[31]:


data.dtypes


# ## MODELS FOLLOW FROM HERE

# In[32]:


## the labels (num_pickups)
num_pickups = data.num_pickups
data.drop("num_pickups", axis=1, inplace=True)


# In[33]:


X_train, X_test, y_train, y_test = train_test_split(data, num_pickups, random_state=0, test_size=0.15)


# In[34]:


X_train_np = X_train.values
X_test_np = X_test.values
y_train_np = y_train.values
y_test_np = y_test.values



from mlxtend.regressor import StackingCVRegressor


# In[133]:
select_lassocv = SelectFromModel(LassoCV(max_iter=1500), threshold="median")


rf_mlxtend = RandomForestRegressor(max_depth=21, 
                                   max_features='sqrt', 
                                   n_estimators=200, 
                                   warm_start=False)

ridge_pipe = make_pipeline(StandardScaler(), select_lassocv, PolynomialFeatures(interaction_only=True),
                           VarianceThreshold(), Ridge(alpha=10.0))

gbt_mlxtend = GradientBoostingRegressor(max_depth=10, 
                                        max_features='log2', 
                                        n_estimators=250, warm_start=False)

xgb_mlxtend = make_pipeline(StandardScaler(), XGBRegressor(colsample_bylevel=0.6,
                                                          colsample_bytree=0.7,
                                                          gamma=0.5,
                                                          learning_rate=0.1,
                                                          max_depth=8,
                                                          n_estimators=250,
                                                          subsample=1.0))

RANDOM_SEED = 10


# ### Stacking Regressor 1

# In[134]:


np.random.seed(RANDOM_SEED)
stack = StackingCVRegressor(regressors=(rf_mlxtend, gbt_mlxtend, xgb_mlxtend), meta_regressor=ridge_pipe)

grid_stack1 = GridSearchCV(
    estimator=stack, 
    param_grid={}, 
    cv=5,
    verbose=3, 
    scoring="r2", 
    refit=True
)


# In[ ]:


grid_stack1.fit(X_train.values, y_train.values)




print(grid_stack1.best_score_)
print(grid_stack1.score(X_test, y_test))

joblib.dump(grid_stack1.best_estimator_, "gridSearch_Models/model_stack_rfgbtxgb_mrcv.pkl")
