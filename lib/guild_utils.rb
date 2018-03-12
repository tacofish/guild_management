require_relative './blizz_client.rb'
require 'psych'
require 'date'

module GuildUtils

  def populate_guild_members(client, realm, guilds)
    if guilds.class == Array
      members = []
      guilds.each do |guild, num|
         list = JSON.parse(client.get_members(guild.to_s, realm))
         members << list if !(list.nil? || list.empty?)
      end
    else
      members = JSON.parse(client.get_members(guilds.to_s, realm))
    end

    members
  end

  def get_staff_alt_list(staff)
    alts = []
    staff.each do |member|
      alts << member["characters"]
    end
    alts.flatten
    alts
  end

  def roster_reconcile(staff_member, staff_roster, guilds, ranks)
    staff_end = {}
    staff_roster.each do |staff|
      if staff["characters"].map(&:strip).include? staff_member["character"]["name"].strip
        if staff["rank_num"] < staff_member["rank"] || staff["rank_num"] > staff_member["rank"]
          staff_end[:main] = staff["name"]
          staff_end[:name] = staff_member["character"]["name"]
          staff_end[:guild] = guilds[staff_member["character"]["guild"]] || "Guildless"
          staff_end[:rank] = ranks[staff["rank_num"]]
        end
      end
    end
    return staff_end
  end

end
