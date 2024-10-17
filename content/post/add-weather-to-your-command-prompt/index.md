---
title: "Add Weather to Your Command Prompt"
date: 2023-07-14
description: "Stop living uncivilized. Weather at a glance in your command prompt can be yours too!"
image: "cover.jpg"
categories:
- Scripts
keywords:
- bashrc
- bash
- weather
- wttr.in
- openweathermap.org
- command prompt
---
Just because you live in the terminal doesn't mean you can't have up to date weather at a glance. Sure there's other tools out there for complete weather forecast. In fact, one of the components of this project is perfect for getting a complete forecast in your terminal. [`wttr.in`](https://github.com/chubin/wttr.in) is a console-oriented weather forecast service. It is in their words, "the right way to `curl` the weather!" I agree; I love it! But what if you want the temperature and condition outside in a quick glance anywhere in the terminal? You would have to have it in the command prompt itself. This is what I set out to do with this project!

## Setting the API key

I want to use two weather providers in this project. The first one is wttr.in. The second one is [openweathermap.org](https://api.openweathermap.org). This way I can have redundancy if the first one is down, which it does from time to time. Openweathermap.org isn't as straight forwad as simply `grep`-ing the information like we will with wttr.in. I need to first set an API key, which is provided for free from openweathermap.org. This function does this:

```
function __set_weather_api() {
  read -p $'Please enter your Openweather.org API key: ' api_key
  # Perform a test request to validate the API key
  response=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=London,uk&appid=$api_key")
  if [[ $response =~ "Invalid API key" ]]; then
    echo "Invalid API key. Please enter a valid OpenWeatherMap API key."
    __set_weather_api
  else
    printf "API_KEY=%s\n" "$api_key" > ~/.weather_api
  fi
}
```

When ever I call `__set_weather_api` I will get a prompt asking me to enter my API key. Afterwards, the function conducts a quick test to check if the API key is indeed valid.

## Setting the Location

The next task to accomplish is providing the weather function with our location. The easy route would be to just hard code the location in. But, I wanted to make this script portable in case others wanted to use it. Also, where's the fun in that?!

```
function __set_location() {
  if [ ! -f ~/.weather_api ]; then
    __set_weather_api
  else
    source ~/.weather_api
  fi
```
First, this script checks to see if `weather_api` is set. If not, it calls the `__set_weather_api` funtion. If it is set, this function sources it.
```
  read -p $'Location needs to be set for the weather function.\x0aEnter your 5-digit zip code: ' zip_code
  read -p $'Please enter your two-digit alphabetic country code: ' country_code
  country_code=$(echo "$country_code" | tr '[:lower:]' '[:upper:]')

  valid_country_code=$(curl -s https://gist.githubusercontent.com/ssskip/5a94bfcd2835bf1dea52/raw/3b2e5355eb49336f0c6bc0060c05d927c2d1e004/ISO3166-1.alpha2.json | jq -r)
  if [[ $valid_country_code != *"$country_code"* ]]; then
    __set_location
  fi

  if [[ $zip_code =~ ^[0-9]{5}$ ]]; then
    DATA=$(curl -s "http://api.openweathermap.org/geo/1.0/zip?zip=$zip_code,$country_code&appid=$API_KEY")
    lattitude=$(echo "$DATA" | jq -r '.lat')
    longitude=$(echo "$DATA" | jq -r '.lon')
    printf "ZIP=%s\nCOUNTRY=%s\nLAT=%s\nLON=%s\n" "$zip_code" "$country_code" "$lattitude" "$longitude" > ~/.weather_location
  else
    echo "Invalid zip code. Please enter a valid 5-digit zip code."
    __set_location
  fi
}
```

In the meat of this function, it prompts you for your zip-code and your country code where it checks to see if the country code is valid using a list provided by Github user [ssskip](https://github.com/ssskip). With this information, it uses the API key and converts the zip and country code to lat and long coordinates and then sets the `.weather_location` file.

## Getting the Weather!
Now, we get to the real purpose, getting the weather!

```
function __weather() {
    # Check whether API key exists
    if [ ! -f ~/.weather_api ]; then
      __set_weather_api
    else
      source ~/.weather_api
    fi

    # Check if location file exists
    if [ ! -f ~/.weather_location ]; then
        __set_location
    else
        source ~/.weather_location
    fi
```
First, we make sure our supporting files are available and source them.

```
    # Get the current time
    NOW=$(date +%s)
```
Then, we set the current time. The reason for this is because I don't want it to call every single time the command prompt is called. Instead, I want it update the weather every 30 minutes.
```
    # Check if it's been at least 30 minutes since the last retrieval
    if [[ ! -f ~/.weather ]] || [[ $(expr $NOW - $(date -r ~/.weather +%s)) -ge 1800 ]]; then
        # If so, retrieve the weather and update the file with the current time
       DATA=$(curl -m 5 -s "https://wttr.in/$ZIP?format=1")
       if [[ $? -eq 0 ]] && [[ $DATA != "Unknown location; please try"* ]]; then
         # If successful, extract the temperature and condition
         TEMP=$(echo "$DATA" | awk -F ' ' '{ print $2 }' | sed 's/+//g')
         COND=$(echo "$DATA" | awk -F ' ' '{ print $1 }')
       else
         # If wttr.in fails, try openweathermap.org
         DATA=$(curl -m 5 -s "https://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=$API_KEY&units=imperial")
         if [[ $? -eq 0 ]]; then
           # If successful, extract the temperature and condition
           TEMP=$(echo "$DATA" | jq -r '.main.temp | round')'°F'
           COND=$(echo "$DATA" | jq -r '.weather[0].description')
           if [[ $COND == *"cloud"* ]]; then
             ICON="☁️"
           elif [[ $COND == *"rain"* ]]; then
             ICON="🌧️"
           elif [[ "$COND" == *"snow"* ]]; then
             ICON="❄️"
           else
             ICON="☀️"
           fi
           COND=$ICON
         else
           # If both services fail, use an error message
           TEMP="N/A"
           COND="Weather service unavailable"
         fi
       fi
       echo -n $TEMP $COND > ~/.weather
    fi
    cat ~/.weather
}
```
If it has been 30 minutes since the last weather check, the function will `curl` wttr.in first. If the curl was successful we parse out the temperature and condition and set it in a file called `.weather`. This file, we'll cat afterwards to return the information. If the `curl` was not successful, we try openweathermap.org. The only difference when using openweathermap.org as far as the information provided is concerned is that the condition is in the form of words rather than an icon. So, we convert these words into the appropriate icon with a series of `if` and `elif` statements.

## Adding the Information to the Command Prompt

This script resides in the `.bashrc` script. To focus solely on this script a simplified command prompt calling the weather function looks like this.

```
PROMPT_COMMAND=__prompt_command

__prompt_command() {
    PS1=""
    PS1+="(__weather) \u@\h $ "
}
```
With this, every time the command prompt comes up, it'll call the weather function and give you the weather updated every 30 minutes.

## Extra: tmux Weather

As a little extra treat, we also can use this in our tmux status bar. Simply add
```
set -g status-right "#(cat ~/.weather)"
```
to your tmux config file. Now, tmux got even more civilized with weather information readily available!



