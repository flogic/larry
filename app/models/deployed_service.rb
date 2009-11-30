class DeployedService < ActiveRecord::Base
  belongs_to :host
  belongs_to :service
  belongs_to :deployment
  
  validates_presence_of :host
  validates_presence_of :service
  validates_presence_of :deployment
  
  def deployable
    return nil unless deployment
    deployment.deployable
  end
  
  def instance
    return nil unless deployment
    deployment.instance
  end
  
  def app
    return nil unless deployment
    deployment.app
  end
  
  def customer
    return nil unless deployment
    deployment.customer
  end  
end
