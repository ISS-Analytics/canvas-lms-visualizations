require 'sinatra'

# Custom ~'wrapper' for the Canvas LMS API
class CanvasLmsAPI < Sinatra::Base
  get '/' do
    'Hello'
  end
end
