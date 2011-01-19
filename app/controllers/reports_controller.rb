class ReportsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @now = Time.now
    @month_till_date = OdeskWork.where(:worked_on.gt => @now.beginning_of_month).sum(:earnings).ceil
    @week_till_date = OdeskWork.where(:worked_on.gt => @now.beginning_of_week).sum(:earnings).ceil    
    @financial_quarters = quarters.inject({}) do |hash, quarter|
      hash[quarter[:name]] = OdeskWork.where(:worked_on.gte => quarter[:start], :worked_on.lte => quarter[:end]).sum(:earnings).ceil
      hash
    end
    map = <<MAP
      function() { 
        emit(this.provider_id, {hours: this.hours, earnings: this.earnings}); 
      }
MAP
    reduce = <<REDUCE 
      function(key, values) {
        var sum_hours=0; var sum_earnings=0; 
        values.forEach(function(doc) { 
          sum_hours += doc.hours; sum_earnings += doc.earnings;
        }); 
        return {hours: sum_hours, earnings: sum_earnings};
      };
REDUCE
    @by_individuals = OdeskWork.collection.mapreduce(map, reduce).find().to_a
  end
  
  private
  def quarters
    array = [2010]
    result = []
    array.each do |a|
      date ||= Date.parse("1.4.#{a}") 
      4.times do |i|
        result << {:name => "Q#{i+1}", :start => date.beginning_of_quarter, :end => date.end_of_quarter}
        date = date.end_of_quarter + 1.day
      end
    end
    result
  end
end