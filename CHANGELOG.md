# Changelog

### v2.10.1
- :hammer: Fixed specs for `HandleOutgoingVideo` service

### v2.10.0
- :hammer: Fixed upload duplications problem
- :hammer: Refactored code regarding `HandleOutgoingVideo` service

### v2.9.7
- :bulb: Added more test videos

### v2.9.6
- :bulb: Implemented receive_permanent_error_video link for connection
- :bulb: Implemented receive_long_test_video_path link for connection

### v2.9.5
- :bulb: Allowed ios clients to use auto notification feature

### v2.9.4
- :hammer: API: changed type of connection id from integer to string
- :hammer: Added invitee name to landing connection page (/c/:id requests)

### v2.9.3
- :hammer: Fixed rollbar logging of APNS unregistered users

### v2.9.2
- :hammer: Reverted back legacy app link with events tracking

### v2.9.1
- :bulb: Fire sqs event when user clicks on app link
- :hammer: Refactored code regarding landing page

### v2.9.0
- :star: Implemented AutoNotification feature
- :bulb: Added logging to papertrail service
- :bulb: Added more information for houston errors
- :bulb: Added exceptions when digest auth fails on staging