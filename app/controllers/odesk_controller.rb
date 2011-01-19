class OdeskController < ApplicationController
  before_filter :odesk_required

  def import
    unless session[:odesk_api_token]
      @odesk_connector.frob = params[:frob]
      session[:odesk_api_token] = @odesk_connector.get_token
      session[:odesk_auth_user] = @odesk_connector.auth_user
    end
    @time_reports = []
    odesk_selector = {:select => "worked_on, provider_id, sum(hours), sum(earnings)", :conditions=>{:agency_id=>"activesphere"}}
    RubyDesk::TimeReport.find(@odesk_connector, odesk_selector).each do |work|
      @time_reports << OdeskWork.create!(:worked_on=> work["worked_on"], :provider_id=>work["provider_id"], :hours=>work["hours"], :earnings=>work["earnings"])
    end
  end

  protected
  def odesk_required
    create_odesk_connector
    unless session[:odesk_api_token] || params[:frob]
      session[:odesk_back_url] = request.url
      redirect_to(@odesk_connector.auth_url) and return
    end
  end

  def create_odesk_connector
    @odesk_connector = RubyDesk::Connector.new(ENV['ODESK_API_KEY'], ENV['ODESK_API_SECRET'], session[:odesk_api_token])
    @odesk_connector.auth_user = session[:odesk_auth_user]
    @odesk_connector
  end

  def reaquire_token
    session[:odesk_api_token] = nil
    odesk_required
  end
end