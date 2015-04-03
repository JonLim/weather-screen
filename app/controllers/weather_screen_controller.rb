class WeatherScreenController < ApplicationController
  require 'date'
  
  def index
    if Rails.env.development?
      client_location = Geocoder.coordinates("33 Bay St, Toronto, ON, Canada")
      @client_loc = 'Toronto'
      @client_country = 'Canada'
      @response = get_weather_in_location(client_location[0], client_location[1])
      
      if @client_country == 'United States'
        @client_temp = get_temperature(@response).round(0).to_s + '°F'
      else
        @client_temp = in_celcius(get_temperature(@response)).round(0).to_s + '°C'
      end
      
      @client_icon = get_weather_icon(@response)
      @current_date = get_date(@response)
      @current_time = get_time(@response)
    else
      @client_loc = request.location
      @response = get_weather_in_location(@client_loc.latitude, @client_loc.longitude)
      
      if @client_loc.country == 'United States'
        @client_temp = get_temperature(@response).round(0).to_s + '°F'
      else
        @client_temp = in_celcius(get_temperature(@response)).round(0).to_s + '°C'
      end
      
      @client_icon = get_weather_icon(@response)
      @current_date = get_date(@response)
      @current_time = get_time(@response)
    end
    
  end
  
  def json_test
    if Rails.env.development?
      client_location = Geocoder.coordinates("33 Bay St, Toronto, ON, Canada")
      @client_loc = request.location
      @response = get_weather_in_location(client_location[0], client_location[1])
      @current_time = DateTime.strptime(@response['currently']['time'].to_s, '%s').strftime('%B %e, %Y')
    else
      @client_loc = request.location
      @response = get_weather_in_location(@client_loc.latitude, @client_loc.longitude)
      
      if @client_loc.country == 'United States'
        @client_temp = get_temperature(@response).round(0).to_s + '°F'
      else
        @client_temp = in_celcius(get_temperature(@response)).round(0).to_s + '°C'
      end
      
      @client_icon = get_weather_icon(@response)
      @current_date = get_date(@response)
      @current_time = get_time(@response)
    end
  end
  
  def get_date(response)
    DateTime.strptime(@response['currently']['time'].to_s, '%s').strftime('%B %e, %Y')
  end
  
  def get_time(response)
    Time.now.in_time_zone(@response['timezone']).strftime('%r')
  end
  
  def get_weather_in_location(latitude, longitude)
    call = 'forecast'
    api_key = ENV['WEATHER_SCREEN_DARK_SKY_API']
    url = HTTParty.get("https://api.forecast.io/#{call}/#{api_key}/#{latitude},#{longitude}", :headers => { 'ContentType' => 'application/json' })
    response = JSON.parse(url.body)
  end
  
  def get_temperature(response)
    temperature = response['currently']['temperature']
  end
  
  def get_weather_icon(response)
    case response['currently']['icon']
    when 'clear-day'
      'wi-day-sunny'
    when 'clear-night'
      'wi-night-clear'
    when 'rain'
      'wi-rain'
    when 'snow'
      'wi-snow'
    when 'sleet'
      'wi-sleet'
    when 'wind'
      'wi-windy'
    when 'fog'
      'wi-fog'
    when 'cloudy'
      'wi-cloudy'
    when 'partly-cloudy-day'
      'wi-day-cloudy'
    when 'partly-cloudy-night'
      'wi-night-cloudy'
    else
      'wi-tornado'
    end
  end
  
  def in_celcius(temperature_in_f)
    (temperature_in_f - 32) * 5.0 / 9.0
  end

end
