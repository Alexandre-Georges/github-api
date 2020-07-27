require 'singleton'
require 'rest-client'

module Calls
  class GetRepos
    include Singleton

    PER_PAGE = 10

    def initialize
      @cache = ActiveSupport::Cache::MemoryStore.new
    end
    def call(username:, token:)
      key = "#{username}"
      cached = @cache.read(key)

      if cached.nil?
        # result = JSON.parse(File.read("lib/calls/get_repos.json"))
        response = RestClient.get("https://#{username}:#{token}@api.github.com/user/repos?sort=created&direction=desc&per_page=#{PER_PAGE}")
        if response.code != 200
          raise "unexpected http code: #{response.code}"
        end
        result = JSON.parse(response.body)
        @cache.write(key, result)
        cached = @cache.read(key)
      end
      return { result: cached }
      rescue => e
        { error: e }
    end
  end
end
