class Deployment < ActiveRecord::Base
  belongs_to :deployable
  has_many :deployed_services
  
  validates_presence_of :deployable
  validates_presence_of :reason
  
  def hosts
    deployed_services.collect(&:host).uniq
  end
  
  def instance
    return nil unless deployable
    deployable.instance
  end
  
  def app
    return nil unless deployable
    deployable.app
  end
  
  def customer
    return nil unless deployable
    deployable.customer
  end
  
  def services
    return nil unless deployable
    deployable.services
  end
end
