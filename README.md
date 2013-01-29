__*Deprecated*: Use [Event Tracker](http://www.doorkeeperhq.com/developer/event-tracker-mixpanel-kissmetrics) instead.__

# Mixpanel Rails

Super simple mixpanel integration with Rails that we use for [Doorkeeper](http://www.doorkeeperhq.com/) and others.

## Usage

```ruby
YourApplication::Application.config.mixpanel_rails.token = "mixpanel_token"

class YourApplication < ApplicationController
  use_mixpanel
end

track_with_mixpanel "some event" # track some event, can use in controller and handles redirects
register_with_mixpanel["property"] = "value" # register a property with mixpanel
```
