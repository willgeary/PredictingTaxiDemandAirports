# Predicting Taxi Demand at Airports in NYC

*Will Geary, Keerti Agrawal, Adam Coviensky, Anuj Katiyal*

*Columbia University Data Science Institute*

*Capstone Project Fall 2017*


### Motivation and Background

The large-scale construction at LaGuardia Airport is causing traffic congestion and making transportation
into and out of the airport difficult. When taxis and other car companies work at the airport, they must
report to a hold lot and wait to be dispatched to a taxi queue at one of the terminals. However, there
is often a mismatch between the demand for taxis and the supply. When there is a shortage of taxis,
passengers can end up waiting upwards of an hour. Conversely, when there are too many taxis, drivers
might wait in the hold lot for two or more hours.

### The Data Set

Trip records for yellow taxis, street-hail liveries, and car companies are available on TLCs website stretching
back to 2009. Car company trip records include temporal and spatial information about the pickup
of every trip dispatched by a car company, while the taxi and street-hail livery data includes information
about pickups, drop-offs, and fare information.

Datasets are available at http://www.nyc.gov/html/tlc/html/about/trip record data.shtml

### Project Overview

TLC is asking the students to use our public trip records, flight data, and any other public dataset to
estimate the demand for taxis at the airports at any given time. This will help the TLC and the Port
Authority maintain an optimal flow of taxis into and out of the airport to minimize wait times for both
passengers and drivers. Minimizing wait times will help drivers maximize their earnings, provide better
customer service for passengers, and possibly reduce congestion at the airports.

### Research Goals

The ultimate goal of the project is to minimize wait times both for passengers in the taxi queues at JFK
and LaGuardia and for drivers in the taxi hold lots. By accurately estimating taxi demand, the Port
Authority can better coordinate a constant throughput of taxis, thereby encouraging drivers to choose
to drive to the airport.

### Suggested Output

Suggested output is a predictive model of average taxi demand and optimal throughput at LaGuardia
and John F. Kennedy airports throughout the week, with special attention paid to peak demand times
such as holidays. Estimates should be no less frequent than hourly. The model should be adjustable by
the TLC and the Port Authority to create new estimates based on changes in flight patterns, holidays,
etc.

### Product Follow-Ons (e.g., apps)

An extremely valuable tool for both the Port Authority and taxi drivers would be an app with the following features:

1. Allows drivers to check the taxi supply at the airport
2. Allows drivers to check arrivals at the airport
3. Estimates and tells drivers how many more taxis are needed at any given time
4. Allows drivers to check in or mark that they will be at the airport at a given time
5. Allows the Port Authority to request more taxis at the airport

### Mentor Information
Mentor: Jeff Garber, Director of Technology and Innovation, New York City Taxi and Limousine Commission
