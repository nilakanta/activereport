class OdeskWork
  include Mongoid::Document

  field :worked_on, :type => Date
  field :provider_id
  field :hours, :type => Float, :default => 0.0
  field :earnings, :type => Float, :default => 0.0
  
end