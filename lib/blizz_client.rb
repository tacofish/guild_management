require 'oauth2'
require 'pp'
require 'httparty'
require 'uri'

# Requires oauth key from dev.battle.net
class BlizzClient
  def initialize(params = {})
    @id = params[:id] || raise("Incomplete oAuth keys. Need an ID.")
    @secret = params[:secret] || raise("Incomplete oAuth keys. Need a secret.")
    @region = params[:region] || 'us'
    @game = 'wow' # This may have more options, later. Destiny comes to mind...
    @site = params[:region] ?  "https://#{@region}.api.battle.net/#{@game}" : "https://us.api.battle.net/#{@game}"
    @authorize_uri = "https://#{@region}.battle.net/"
    @token = get_authorization_token
    @client = APIClient.new(token: @token, site: @site, id: @id)
  end

  def get_members(guild = "Currently Online", realm = "Sargeras")
    @client.get_members(@site, guild, realm).response.body
  end

  def get_character_info(character, realm = "Sargeras")
    @client.get_character_info(character, @site, realm).response.body
  end

  private
  def get_authorization_token
    token_uri = "#{@authorize_uri}/oauth/token"
    client = OAuth2::Client.new(
      @id,
      @secret,
      token_url: token_uri
    )
    response = client.client_credentials.get_token.token
    response
  end

  class APIClient
    include HTTParty

    def initialize(params = {})
      @access = params[:id]
      @token = params[:token]
      @options = {
        headers: {
          "User-Agent" => 'Currently Online Guild Tools',
        }
      }
    end

    def get_members(site, guild, realm)
      enc_guild = URI::encode guild
      opts = @options.merge query: {fields: "members", apikey: @access, access_token: @token, locale: "en_us"}
      self.class.get("#{site}/guild/#{realm}/#{enc_guild}", opts)
    end

    def get_character_info(character, site, realm)
      opts = @options.merge query: {fields: "guild", apikey: @access, access_token: @token, locale: "en_us"}
      self.class.get("#{site}/character/#{realm}/#{character}", opts)
    end
  end

end
