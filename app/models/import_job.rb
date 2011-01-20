class ImportJob
  include Mongoid::Document

  field :last_import_date, :type => Date

  def self.run odesk_connector
    @last_job = ImportJob.first
    today = Date.today

    time_reports = []
    worked_on_selector = ((@last_job ? @last_job.last_import_date : Date.civil(2010, 1, 1))...today)
    odesk_selector = {:select => "worked_on, provider_id, sum(hours), sum(earnings)",
                      :conditions=>{:agency_id=>"activesphere", :worked_on => worked_on_selector}}
    RubyDesk::TimeReport.find(odesk_connector, odesk_selector).each do |work|
      time_reports << OdeskWork.create!(:worked_on=> work["worked_on"], :provider_id=>work["provider_id"], :hours=>work["hours"], :earnings=>work["earnings"])
    end

    @last_job = ImportJob.create!(:last_import_date => today) unless @last_job
    @last_job.update_attributes(:last_import_date => today)
    time_reports
  end
end