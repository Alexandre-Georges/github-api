class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  def interactions
    results = Logic::GetInteractions.new.call(
      username: params[:username],
      token: params[:token],
      from: DateTime.parse(params[:from]),
      to: DateTime.parse(params[:to]),
    )
    render json: results, status: 200
  end

  def shoutout_data
    results = Logic::GetShoutoutData.new.call(
      username: params[:username],
      token: params[:token],
    )
    render json: results, status: 200
  end
end
