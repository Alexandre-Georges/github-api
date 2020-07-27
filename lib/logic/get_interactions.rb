require 'rest-client'

module Logic
  class GetInteractions
    def call(username:, token:, from:, to:)
      response = Calls::GetRepos.instance.call(username: username, token: token)

      prs = []
      return [] if response[:error]

      response[:result].each { |repo|
        created_at = DateTime.parse(repo["created_at"])
        next if created_at > to
        response = Calls::GetPullRequests.instance.call(
          username: username,
          token: token,
          repo_owner: repo["owner"]["login"],
          repo_name: repo["name"],
        )
        next if response[:error]
        prs = prs.concat(response[:result])
      }

      user_prs = []
      other_prs = []

      prs.each { |pr|
        created_at = DateTime.parse(pr["created_at"])
        next if created_at > to
        if pr["user"]["login"] == username
          user_prs << pr
        else
          other_prs << pr
        end
      }

      interactions = []
      interactions = interactions.concat(get_interactions_for_user_prs(username: username, token: token, from: from, to: to, prs: user_prs))
      interactions = interactions.concat(get_interactions_for_other_prs(username: username, token: token, from: from, to: to, prs: other_prs))

      interactions_by_type = {}
      interactions.each { |interaction|
        key = "#{interaction[:login]}-#{interaction[:type]}"
        interaction_by_type = interactions_by_type[key] || {
          type: interaction[:type],
          login: interaction[:login],
          avatar_url: interaction[:avatar_url],
          count: 0,
        }
        interaction_by_type[:count] += 1
        interactions_by_type[key] = interaction_by_type
      }

      interaction_sum_up = []
      interactions_by_type.values.each { |value|
        interaction_sum_up << {
          type: value[:type],
          login: value[:login],
          avatar_url: value[:avatar_url],
          count: value[:count],
        }
      }
      interaction_sum_up
    end

    def get_interactions_for_user_prs(username:, token:, from:, to:, prs:)
      interactions = []
      prs.each { |pr|
        interactions = interactions.concat(get_interactions_for_user_pr(
          username: username,
          token: token,
          from: from,
          to: to,
          pr: pr,
        ))
      }
      interactions
    end

    def get_interactions_for_user_pr(username:, token:, from:, to:, pr:)
      repo_owner = pr["head"]["repo"]["owner"]["login"]
      repo_name = pr["head"]["repo"]["name"]
      pr_number = pr["number"]

      interactions = []
      response = Calls::GetPrComments.instance.call(
        username: username,
        token: token,
        repo_owner: repo_owner,
        repo_name: repo_name,
        pr_number: pr_number,
      )
      return interactions if response[:error]
      response[:result].each { |comment|
        created_at = DateTime.parse(comment["created_at"])
        next if created_at < from || created_at > to || comment["user"]["login"] == username
        interactions << create_interaction(
          type: "COMMENT_ON_USER_PR",
          login: comment["user"]["login"],
          avatar_url: comment["user"]["avatar_url"],
          date: comment["created_at"],
        )
      }

      response = Calls::GetPrReviews.instance.call(
        username: username,
        token: token,
        repo_owner: repo_owner,
        repo_name: repo_name,
        pr_number: pr_number,
      )
      return interactions if response[:error]
      response[:result].each { |review|
        submitted_at = DateTime.parse(review["submitted_at"])
        next if submitted_at > to
        if submitted_at >= from && review["user"]["login"] != username
          interactions << create_interaction(
            type: "REVIEW_ON_USER_PR",
            login: review["user"]["login"],
            avatar_url: review["user"]["avatar_url"],
            date: review["submitted_at"]
          )
          interactions = interactions.concat(get_interactions_for_user_review(
            username: username,
            token: token,
            from: from,
            to: to,
            repo_owner: repo_owner,
            repo_name: repo_name,
            pr_number: pr_number,
            review_id: review["id"],
          ))
        end
      }
      interactions
    end

    def get_interactions_for_user_review(username:, token:, from:, to:, repo_owner:, repo_name:, pr_number:, review_id:)
      interactions = []
      response = Calls::GetPrReviewComments.instance.call(
        username: username,
        token: token,
        repo_owner: repo_owner,
        repo_name: repo_name,
        pr_number: pr_number,
        review_id: review_id,
      )
      return interactions if response[:error]
      response[:result].each { |comment|
        created_at = DateTime.parse(comment["created_at"])
        next if created_at < from || created_at > to || comment["user"]["login"] == username
        interactions << create_interaction(
          type: "REVIEW_COMMENT_ON_USER_PR",
          login: comment["user"]["login"],
          avatar_url: comment["user"]["avatar_url"],
          date: comment["created_at"]
        )
      }
      interactions
    end

    def get_interactions_for_other_prs(username:, token:, prs:, from:, to:)
      interactions = []
      prs.each { |pr|
        interactions = interactions.concat(get_interactions_for_other_pr(
          username: username,
          token: token,
          from: from,
          to: to,
          pr: pr,
        ))
      }

      interactions
    end

    def get_interactions_for_other_pr(username:, token:, from:, to:, pr:)
      repo_owner = pr["head"]["repo"]["owner"]["login"]
      repo_name = pr["head"]["repo"]["name"]
      pr_number = pr["number"]
      pr_user = pr["user"]["login"]
      pr_avatar_url = pr["user"]["avatar_url"]

      interactions = []

      response = Calls::GetPrComments.instance.call(
        username: username,
        token: token,
        repo_owner: repo_owner,
        repo_name: repo_name,
        pr_number: pr_number,
      )
      return interactions if response[:error]
      response[:result].each { |comment|
        created_at = DateTime.parse(comment["created_at"])
        next if created_at < from || created_at > to || comment["user"]["login"] != username
        interactions << create_interaction(
          type: "USER_COMMENT_ON_PR",
          login: pr_user,
          avatar_url: pr_avatar_url,
          date: comment["created_at"],
        )
      }

      response = Calls::GetPrReviews.instance.call(
        username: username,
        token: token,
        repo_owner: repo_owner,
        repo_name: repo_name,
        pr_number: pr_number,
      )
      return interactions if response[:error]
      response[:result].each { |review|
        submitted_at = DateTime.parse(review["submitted_at"])
        next if submitted_at > to
        if review["user"]["login"] == username
          if submitted_at >= from
            interactions << create_interaction(
              type: "USER_REVIEW_ON_PR",
              login: pr_user,
              avatar_url: pr_avatar_url,
              date: review["submitted_at"]
            )
          end
          interactions = interactions.concat(get_interactions_for_other_review(
            username: username,
            token: token,
            from: from,
            to: to,
            repo_owner: repo_owner,
            repo_name: repo_name,
            pr_number: pr_number,
            pr_user: pr_user,
            pr_avatar_url: pr_avatar_url,
            review_id: review["id"],
          ))
        end
      }
      interactions
    end

    def get_interactions_for_other_review(username:, token:, from:, to:, repo_owner:, repo_name:, pr_number:, pr_user:, pr_avatar_url:, review_id:)
      interactions = []
      response = Calls::GetPrReviewComments.instance.call(
        username: username,
        token: token,
        repo_owner: repo_owner,
        repo_name: repo_name,
        pr_number: pr_number,
        review_id: review_id,
      )
      return interactions if response[:error]
      response[:result].each { |comment|
        created_at = DateTime.parse(comment["created_at"])
        next if created_at < from || created_at > to || comment["user"]["login"] != username
        interactions << create_interaction(
          type: "USER_REVIEW_COMMENT_ON_PR",
          login: pr_user,
          avatar_url: pr_avatar_url,
          date: comment["created_at"]
        )
      }
      interactions
    end

    def create_interaction(type:, login:, avatar_url:, date:)
      {
        type: type,
        login: login,
        avatar_url: avatar_url,
        date: date,
      }
    end
  end
end
