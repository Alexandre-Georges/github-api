require 'singleton'
require 'rest-client'

module Calls
  class GetPrReviewComments
    include Singleton

    PER_PAGE = 100

    def initialize
      @cache = ActiveSupport::Cache::MemoryStore.new
    end
    def call(username:, token:, repo_owner:, repo_name:, pr_number:, review_id:)
      key = "#{username}-#{repo_owner}-#{repo_name}-#{pr_number}-#{review_id}"
      cached = @cache.read(key)

      if cached.nil?
        # result = JSON.parse(File.read("lib/calls/get_pr_review_comments_#{pr_number}.json"))
        response = RestClient.get("https://#{username}:#{token}@api.github.com/repos/#{repo_owner}/#{repo_name}/pulls/#{pr_number}/reviews/#{review_id}/comments?per_page=#{PER_PAGE}")
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
