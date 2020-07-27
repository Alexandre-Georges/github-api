require 'rest-client'

module Logic
  class GetShoutoutData
    def call(username:, token:)
      # This would require its own logic but most of it would be similar to interactions'
      interactions = Logic::GetInteractions.new.call(
        username: username,
        token: token,
        from: 7.days.ago,
        to: DateTime.now,
      )

      interactions_by_login = {}
      interactions.each { |interaction|
        key = interaction[:login]
        interactions_for_login = interactions_by_login[key] || {
          login: key,
          avatar_url: interaction[:avatar_url],
          count: 0,
        }
        interactions_for_login[:count] += interaction[:count]
        interactions_by_login[key] = interactions_for_login
      }

      shoutout_data = []
      interactions_by_login.values.each { |value|
        shoutout_data << value
      }
      shoutout_data.sort { |a, b| b[:count] <=> a[:count] }
    end
  end
end
