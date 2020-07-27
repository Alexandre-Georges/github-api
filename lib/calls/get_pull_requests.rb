require 'singleton'
require 'rest-client'

module Calls
  class GetPullRequests
    include Singleton

    PER_PAGE = 50

    def initialize
      @cache = ActiveSupport::Cache::MemoryStore.new
    end
    def call(username:, token:, repo_owner:, repo_name:)
      key = "#{username}-#{repo_owner}-#{repo_name}"
      cached = @cache.read(key)

      if cached.nil?
        # result = JSON.parse(File.read("lib/calls/get_pull_requests.json"))
        response = RestClient.get("https://#{username}:#{token}@api.github.com/repos/#{repo_owner}/#{repo_name}/pulls?state=all&per_page=#{PER_PAGE}&sort=created&direction=desc")
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
