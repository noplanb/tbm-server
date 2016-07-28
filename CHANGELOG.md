# Changelog

### 2.10.4-wip.9
- :arrow_up: Removed unnecessary code
- :arrow_up: Bumped nokogiri gem
- :hammer: Fixed wercker build and deploy configuration

### 2.10.4-wip.8
- :arrow_up: Added event dispatcher from zazo-tools gem

### 2.10.4-wip.7
- :arrow_up: Removed unnecessary gems
- :arrow_up: Added logger from zazo-tools gem

### 2.10.4-wip.6
- :arrow_up: Move some stuff to zazo-tools gem

### 2.10.4-wip.5
- :arrow_up: Refactor ModelDecorator

### 2.10.4-wip.4
- :bulb: Included abilities field for each user to messages#index response
- :arrow_up: Updated .pryrc

### 2.10.4-wip.3
- :arrow_up: Removed unnecessary code
- :hammer: Fixed rack middleware for api documentation

### 2.10.4-wip.2
- :hammer: Fixed messages#create API (set id as optional parameter)
- :hammer: Fixed error messages for messages API

### 2.10.4-wip.1
- :bulb: Implemented new messages API CRUD resource
- :bulb: Implemented auto-notifications for new messages API
- :bulb: Changed setup for productive development
- :arrow_up: Added new long test video
- :arrow_up: Implemented rack middleware to serve static docs files with basic auth
- :arrow_up: Refactored code

### 2.10.4
- :hammer: Add new APNS certs

### 2.10.3
- :bulb: Added Mixpanel link to landing footer to get free service

### 2.10.2
- :hammer: Fixed bug with welcome message feature
- :hammer: Refactored specs for `HandleOutgoingVideo` service

### 2.10.1
- :hammer: Fixed specs for `HandleOutgoingVideo` service

### 2.10.0
- :hammer: Fixed upload duplications problem
- :hammer: Refactored code regarding `HandleOutgoingVideo` service

### 2.9.7
- :bulb: Added more test videos

### 2.9.6
- :bulb: Implemented receive_permanent_error_video link for connection
- :bulb: Implemented receive_long_test_video_path link for connection

### 2.9.5
- :bulb: Allowed ios clients to use auto notification feature

### 2.9.4
- :hammer: API: changed type of connection id from integer to string
- :hammer: Added invitee name to landing connection page (/c/:id requests)

### 2.9.3
- :hammer: Fixed rollbar logging of APNS unregistered users

### 2.9.2
- :hammer: Reverted back legacy app link with events tracking

### 2.9.1
- :bulb: Fire sqs event when user clicks on app link
- :hammer: Refactored code regarding landing page

### 2.9.0
- :star: Implemented AutoNotification feature
- :bulb: Added logging to papertrail service
- :bulb: Added more information for houston errors
- :bulb: Added exceptions when digest auth fails on staging
