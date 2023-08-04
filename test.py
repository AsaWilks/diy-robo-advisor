# Import libraries

import math
import numpy as np
import pandas as pd
import yfinance as yf
import matplotlib.pyplot as plt
plt.style.use('seaborn-v0_8-pastel')

from sklearn.preprocessing import MinMaxScaler

#import tensorflow as tf
#import keras
#from keras import layers

from keras.models import Sequential
from keras.layers import Dense, LSTM, Dropout

# Read the stock data
vti = yf.Ticker("VTI").history(period="5y")

# Plot the closing price history of the stock
'''
plt.figure(figsize=(16, 8))
plt.title('Close Price History', fontweight='bold', fontsize=20)
plt.plot(vti['Close'], color='green')
plt.xlabel('Date', fontsize=18, fontweight='bold')
plt.ylabel('Close Price ($)', fontsize=18, fontweight='bold')
plt.show()
'''

##
# training set
##

# create a new dataframe with only close  column
close_vti = vti.filter(['Close'])

# save the price values to a numpy array
close_vti_arr = close_vti.values

# get the length of training data (80% of sample size)
train_size = int(np.round(len(close_vti_arr) * .8))
train_size

# scale the data
sc = MinMaxScaler(feature_range=(0, 1))
close_vti_arr_scaled = sc.fit_transform(close_vti_arr)
close_vti_arr_scaled

# create the scaled train data set
train_scaled = close_vti_arr_scaled[0:train_size, :]
train_scaled

# create x_train_scaled y_train_scaled data sets

x_train_scaled = [] # empty list
y_train_scaled = [] # empty list

for i in range(60, len(train_scaled)):
    x_train_scaled.append(train_scaled[i-60:i, 0]) # previous 60 days of values
    y_train_scaled.append(train_scaled[i, 0]) # target value

# print first values from both x_train_scaled and y_train_scaled
# first 60 days values (feature) & 61th day value (target)
x_train_scaled[0], y_train_scaled[0]

# convert x_train_scaled and y_train_scaled lists to numpy arrays
x_train_scaled,y_train_scaled = np.array(x_train_scaled),np.array(y_train_scaled)

# reshape the train data as 3-dimensional array
x_train_scaled = np.reshape(x_train_scaled, (x_train_scaled.shape[0], x_train_scaled.shape[1], 1))

# build the lstm network
model = Sequential()
model.add(LSTM(units=50,
               return_sequences=True,
               input_shape=(x_train_scaled.shape[1],1)))
model.add(Dropout(.5))
model.add(LSTM(units=50,
               return_sequences=False))
model.add(Dropout(.5))
model.add(Dense(25))
model.add(Dense(1))

# compile and fit the lstm network
model.compile(loss='mean_squared_error', optimizer='adam')
model.fit(x_train_scaled, y_train_scaled, epochs=10,
          batch_size=1, verbose=-1)

# create the scaled test data set (20% of the sample size)
test_scaled = close_vti_arr_scaled[train_size - 60:, :]

# Create x_test_scaled y_test data sets
x_test_scaled = [] # empty list
y_test = close_vti_arr[train_size:, :] # unscaled array

for i in range(60, len(test_scaled)):
    x_test_scaled.append(test_scaled[i-60:i, 0]) # previous 60 days of values

# convert to a numpy array
x_test_scaled = np.array(x_test_scaled)

# reshape the data
x_test_scaled = np.reshape(x_test_scaled,
                           (x_test_scaled.shape[0],
                            x_test_scaled.shape[1], 1))

# predict the closing values
preds = model.predict(x_test_scaled)
preds = sc.inverse_transform(preds)

# rmse
rmse =np.sqrt(np.mean(((preds - y_test)**2)))
rmse

# plot the actual values vs predictions
train = close_vti[:train_size]
valid = close_vti[train_size:]
valid['Predictions'] = preds

plt.figure(figsize=(16,8))
plt.title('Model')
plt.xlabel('Date', fontsize=18, fontweight='bold')
plt.ylabel('Close Price ($)', fontsize=18, fontweight='bold')
plt.plot(train['Close'], color='green')
plt.plot(valid[['Close', 'Predictions']])
plt.legend(['Train', 'Val', 'Predictions'], loc='lower right')
plt.show()


'''
model = keras.Sequential()
    [
    layers.LSTM(units=50,
               return_sequences=True,
               input_shape=(x_train_scaled.shape[1], 1),
    layers.Dropout(.5),
    layers.LSTM(units=50,
               return_sequences=False),
    layers.Dropout(.5),
    layers.Dense(25),
    layers.Dense(1)
    ]
'''
