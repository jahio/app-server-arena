# --
# basic sinatra app to do three things:
# * tell you what app server is running this code (/server)
# * compute pi to 10,000 decimal places as a pseudo-task to fake real work
# * do a twitter search, simulating network wait
class AppServerArena < Sinatra::Base
  get '/' do
    index
  end

  get '/server' do
    server
  end

  get '/pi' do
    pi
  end

  get '/borat' do
    borat
  end

  get '/sleep' do
    do_sleep
  end

  get '/random' do
    do_random
  end

private
  def do_random
    num = 1 + rand(10) # random number b/t 1 and 10
    case num
    when 1..5
      server
    when 6..7
      do_sleep
    else
      pi
    end
  end

  def do_sleep
    sleep 5
    erb :sleep
  end

  def borat
    twitter = twitter_consumer
    response = twitter.request(:get, 'https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=devops_borat&count=10')

    @tweets = JSON.parse(response.body)
    erb :borat
  end

  def server
    # Figure out which app server we're running under
    @current_server = app_server

    # Set the request and response objects for page rendering
    @request = request
    @response = response
    erb :server
  end

  def pi
    @pi = calc_pi(20_000)
    erb :pi
  end

  def index
    erb :index
  end

  def twitter_consumer
    creds = YAML.load_file(File.join(File.dirname(__FILE__), 'config', 'twitter.yml'))
    consumer = OAuth::Consumer.new(creds["consumer_key"], creds["consumer_secret"],
      {
        site: 'https://api.twitter.com',
        scheme: :header
      }
    )

    token_hash = { oauth_token: creds["oauth_token"], oauth_token_secret: creds["oauth_secret"] }

    return OAuth::AccessToken.from_hash(consumer, token_hash)
  end

  def app_server
    # Figure out which server we're running under
    ["Rainbows", "Puma", "Thin", "Unicorn", "PhusionPassenger"].each do |s|
      if Module.const_defined? s
        return s
      end
    end

    # No return yet, push out nil because we don't know the app server.
    return nil
  end

  # These two methods are to be used for a semi-computationally expensive task,
  # simulating real wock without the loss of control that would come from
  # abdicating control to IO (e.g. database, HTTP API, file access, etc.)
  # Found at stack overflow:
  # http://stackoverflow.com/questions/3137594/how-to-create-pi-sequentially-in-ruby
  def arccot(x, unity)
   xpow = unity / x
   n = 1
   sign = 1
   sum = 0
   loop do
       term = xpow / n
       break if term == 0
       sum += sign * (xpow/n)
       xpow /= x*x
       n += 2
       sign = -sign
   end
   sum
  end

  def calc_pi(digits = 10000)
     fudge = 10
     unity = 10**(digits+fudge)
     pi = 4*(4*arccot(5, unity) - arccot(239, unity))
     pi / (10**fudge)
  end
end