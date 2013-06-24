class App < Sinatra::Base
  helpers ApplicationHelpers
  
  configure do
    set :hipchat_url, 'http://api.hipchat.com'
    set :app_config, YAML.load_file('config/app_config.yml')
  end
  
  get '/' do
    conn = Faraday.new(:url => settings.hipchat_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    
    response = conn.get '/v1/rooms/list', { :format => 'json', :auth_token => params[:token] }
    
    @rooms = JSON.parse(response.body)["rooms"]
    
    erb :'pages/index'
  end
  
  get '/room/:id' do |id|
    conn = Faraday.new(:url => settings.hipchat_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    
    response = conn.get '/v1/rooms/history', { :format => 'json', :auth_token => params[:token], :room_id => id, :date => DateTime.now.strftime('%Y-%m-%d') }
    
    history = JSON.parse(response.body)["messages"]
    
    history.reject! { |hist| DateTime.parse(hist["date"]).strftime("%d %b %Y") != DateTime.now.strftime("%d %b %Y")  }
    
    tmp = []
    
    history.each do |hist|
      next if settings.app_config["settings"]["exclude_nicks"].include? hist["from"]["name"]
      entry = {}
      entry["date"] = DateTime.parse(hist["date"]).strftime("%d %b %Y")
      entry["name"] = hist["from"]["name"]
      tmp << entry
    end
    
    res = Hash.new(0)
    tmp.each do |t|
      res[t["name"]] += 1
    end
    
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