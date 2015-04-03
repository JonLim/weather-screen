class WeatherScreenController < ApplicationController
  require 'date'
  
  def index
    if Rails.env.development?
      client_location = Geocoder.coordinates("33 Bay St, Toronto, ON, Canada")
      @client_loc = 'Toronto'
      @response = get_weather_in_location(client_location[0], client_location[1])
      @current_time = DateTime.strptime(@response['currently']['time'].to_s, '%s').strftime('%B %e, %Y')
    else
      @client_ip = request.location
      @response = get_weather_in_location(@client_ip.latitude, @client_ip.longitude)
      @current_time = DateTime.strptime(@response['currently']['time'].to_s, '%s').strftime('%B %e, %Y')
    end
    
  end
  
  def get_weather_in_location(latitude, longitude)
    call = 'forecast'
    api_key = ENV['WEATHER-SCREEN_DARK_SKY_API']
    url = HTTParty.get("https://api.forecast.io/#{call}/#{api_key}/#{latitude},#{longitude}", :headers => { 'ContentType' => 'application/json' })
    response = JSON.parse(url.body)
  end

end
