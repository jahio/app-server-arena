# --
# basic sinatra app to do three things:
# * tell you what app server is running this code (/server)
# * compute pi to 10,000 decimal places as a pseudo-task to fake real work
# * do a twitter search, simulating network wait
class MyApp < Sinatra::Base
  get '/' do
    body = '<!DOCTYPE html>'
    body << <<-EOF     
    <html>
    <body>
    <a href="/server">Server Info</a><br>
    <a href="/pi">Calculate &Pi;</a><br>
    <a href="/api">Do something waiting on network IO</a>
    </body>
    </html>
    EOF
  end

  get '/server' do
    # Figure out which app server we're running under
    current_server = app_server
    "Hello, world! Currently running under #{current_server || 'UNKNON - Maybe Passenger?'}."
  end

  get '/pi' do
    "\n\nI calculated &Pi; to 10k digits for you! See below:\n\n#{calc_pi(10_000)}"
  end

  get '/api' do
    twitter = twitter_consumer
    response = twitter.request(:get, 'https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=devops_borat&count=10')
    body = '<!DOCTYPE html><html><body>'
    body << "Here's what Twitter came back with:\n\n<ul>\n"
    JSON.parse(response.body).each do |x|
      body << "<li>#{x["text"]}</li>"
    end
    body << "</ul>\n</body>\n</html>"
    return body
  end

private

  def twitter_consumer
    creds = YAML.load_file(File.join(File.dirname(__FILE__), 'twitter.yml'))
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
    ["Rainbows", "Puma", "Thin", "Unicorn"].each do |s|
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