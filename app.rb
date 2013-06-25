class App < Sinatra::Base
  helpers ApplicationHelpers
  
  configure do
    set :hipchat_url, 'http://api.hipchat.com'
    set :app_config, YAML.load_file('config/app_config.yml')
    Utilities.conn = Faraday.new(:url => settings.hipchat_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
  
  get '/' do
    @title = "Rooms"
    
    erb :'pages/index'
  end
  
  get '/rooms' do
    response = Utilities.conn.get '/v1/rooms/list', { :format => 'json', :auth_token => params[:token] }
    return {"error" => "The HipChat API returned an error. Error code: #{response.status}"}.to_json if response.status.to_i > 200
    
    @rooms = JSON.parse(response.body)["rooms"]
    render partial: 'rooms'
  end
  
  get '/room/:id' do |id|
    params[:from] = Date.today.strftime('%Y-%m-%d') unless params[:from]
    @filter_date = DateTime.parse(params[:from])
    
    response = Utilities.conn.get '/v1/rooms/history', { :format => 'json', :auth_token => params[:token], :room_id => id, :date => @filter_date.strftime('%Y-%m-%d') }
    return {"error" => "The HipChat API returned an error."}.to_json if response.status.to_i > 200
    history = JSON.parse(response.body)["messages"]
    
    response = Utilities.conn.get '/v1/rooms/show', { :format => 'json', :auth_token => params[:token], :room_id => id }
    return {"error" => "The HipChat API returned an error."}.to_json if response.status.to_i > 200
    room_details = JSON.parse(response.body)["room"]
    @title = room_details["name"]
    
    # this shouldn't be required, because we already ask for this date in the REST call
    history.reject! { |hist| DateTime.parse(hist["date"]).strftime("%d %b %Y") != @filter_date.strftime("%d %b %Y")  }
    
    # add the user names to an array so we can count it later
    tmp = []
    history.each do |hist|
      next if settings.app_config["settings"]["exclude_nicks"].include? hist["from"]["name"]
      tmp << hist["from"]["name"]
    end
    
    # count messages
    res = Hash.new(0)
    tmp.each do |t|
      res[t] += 1
    end
    
    #build result for highcharts chart
    @result = []
    res.each do |k, v|
      t = {}
      t["name"] = k
      t["y"] = v
      @result << t
    end
    
    erb :'pages/history'
  end  
end