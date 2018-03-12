require_relative '../lib/blizz_client.rb'
require_relative '../lib/guild_utils.rb'
require 'hashie'
require 'optparse'
require 'time'
require 'optparse'
require 'ostruct'
require 'psych'
require 'pp'

class ToolOpts
  def self.parse(args)
    options = OpenStruct.new
    options.location = "./#{Time.now.utc.to_i}-rosterreport.yaml"
    options.time = false
    options.rank = true
    options.region = "us"
    options.game = "wow"
    options.faction = "alliance"
    options.verbose = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: example.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-l", "--location LOCATION",
              "The LOCATION to save the report to") do |loc|
        options.library = loc
      end

      opts.on("-t", "--time",
              "Run last login as part of the report") do |t|
        options.time = t
      end

      opts.on("-n FACTION", "--faction FACTION", "Faction to run the report for ('horde' or 'alliance')") do |f|
        options.faction = f
      end

      opts.on("-r REGION", "--region=REGION", "Blizzard region to call.") do |r|
        options.region = r
      end

      opts.on("-i ID", "--id=ID", "Blizzard access key.") do |i|
        options.id = i
      end

      opts.on("-g GUILDFILE", "--guildfile=GUILDFILE", "File containing guild list") do |g|
        options.guildfile = g
      end

      opts.on("-R ROSTERFILE", "--rosterfile=ROSTERFILE", "File containing guild members to be reconciled") do |r|
        options.rosterfile = r
      end

      opts.on("-f RANKFILE", "--rankfile=RANKFILE", "File containing rank mapping") do |f|
        options.rankfile = f
      end

      opts.on("-s SECRET", "--secret=SECRET", "Blizzard API secret.") do |s|
        options.secret = s
      end

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options.verbose = v
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.on_tail("--version", "Show version") do
        puts ::Version.join('.')
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end  # parse()

end  # class OptparseExample
include GuildUtils
options = ToolOpts.parse(ARGV)

file = options.location

client = BlizzClient.new(id: options.id,
                         secret: options.secret,
                         region: options.region,
                         game: options.game)
members = []
staff = []
alts = []

guilds = Psych.load_file(options.guildfile)
staff = Psych.load_file(options.rosterfile)
ranks = Psych.load_file(options.rankfile)

guilds.each do |guild, num|
  members = options.faction == "horde" ? populate_guild_members(client, "illidan", guild) : populate_guild_members(client, "sargeras", guild)
  members.compact
  staff_name_list = get_staff_alt_list(staff)
  if !members["members"].nil?
    members["members"].each do |character|
      roster_look = roster_reconcile(character, staff, guilds, ranks)
      pp roster_look if !(roster_look.nil? || roster_look.empty?)
    end
  end
end
