class Deployable < ActiveRecord::Base
  belongs_to :instance
  has_many :all_deployments, :class_name => 'Deployment'
  
  validates_presence_of :instance

  serialize :snapshot
  
  def self.deploy_from_instance(instance, params)
    create!(:instance => instance).deploy(params)
  end
  
  def deploy(params)
    Deployment.deploy_from_deployable(self, params)
  end
  
  def snapshot
    self[:snapshot] || {}
  end

  def deployments
    all_deployments.active
  end
  
  def deployed_services
    deployments.collect(&:deployed_services).flatten.uniq
  end
  
  def all_deployed_services
    all_deployments.collect(&:deployed_services).flatten.uniq
  end
  
  def hosts
    deployments.collect(&:hosts).flatten.uniq
  end
  
  def all_hosts
    all_deployments.collect(&:hosts).flatten.uniq
  end
  
  def app
    return nil unless instance
    instance.app
  end
  
  def customer
    return nil unless instance
    instance.customer
  end
  
  def services
    return nil unless instance
    instance.services
  end
  
  def service_parameters(service_name)
    return {} unless the_service = services.find_by_name(service_name)
    instance.configuration_parameters.slice(*the_service.parameters)
  end
  
  def last_deployment_time
    return "unknown" if all_deployments.blank?
    ordered_deployments.first.start_time.to_s(:db)
  end
  
  def last_deployment_reason
    return "unknown" if all_deployments.blank?
    ordered_deployments.first.reason
  end
  
  def ordered_deployments
    all_deployments.sort_by {|d| 
      [ -d.start_time.to_i, 
        -1*(d.end_time ? 0 : 1),  
        -1*(d.end_time ? d.end_time.to_i : 0), 
        -d.created_at.to_i ] 
    }
  end
end