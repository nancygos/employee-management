module Api
  class OverviewController < ApplicationController

    def show
      render json: Pay::Overview.new.to_h
    end
  end
end