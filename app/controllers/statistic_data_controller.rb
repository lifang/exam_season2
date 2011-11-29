# encoding: utf-8
class StatisticDataController < ApplicationController

  def index
    @register=StatisticData.register_num
    @action=StatisticData.action_num
    web_buyer=StatisticData.web_buyer_num
    competes_buyer=StatisticData.competes_buyer_num
    @buyers=web_buyer["0"][0].ids+competes_buyer["0"][0].ids
    @fee_num=web_buyer["0"][0].ids*36+competes_buyer["0"][0].ids*10

  end

end
