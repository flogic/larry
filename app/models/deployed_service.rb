class DeployedService < ActiveRecord::Base
  belongs_to :host
  belongs_to :deployment
  
  validates_presence_of :host
  validates_presence_of :deployment
  validates_presence_of :service_name
  
  serialize :parameters
  
  def parameters
    self[:parameters] || {}
  end
  
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
  
  def configuration_hash
    { :name => service_name, :parameters => parameters.dup }
  end
end
