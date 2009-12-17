class Host < ActiveRecord::Base
  has_many :all_deployed_services, :class_name => 'DeployedService', :foreign_key => 'host_id'
  has_many :all_deployments, :class_name => 'Deployment', :through => :all_deployed_services, :source => 'deployment'
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  default_scope :order => :name
  
  before_destroy :safe_to_delete?

  def deployments
    all_deployments.active
  end
  
  def deployed_services
    deployments.collect(&:deployed_services).flatten
  end
  
  def deployables
    deployments.collect(&:deployable).uniq
  end
  
  def all_deployables
    all_deployments.collect(&:deployable).uniq
  end

  def instances
    deployments.collect(&:instance).uniq
  end

  def all_instances
    all_deployments.collect(&:instance).uniq
  end

  def apps
    deployments.collect(&:app).uniq
  end
  
  def all_apps
    all_deployments.collect(&:app).uniq
  end

  def customers
    deployments.collect(&:customer).uniq
  end
  
  def all_customers
    all_deployments.collect(&:customer).uniq
  end

  def configuration
    services_by_instance = deployed_services.inject({}) {|h, ds| h[ds.instance] ||= []; h[ds.instance] << ds; h}
    services_by_instance.keys.inject([]) do |config, deployed_instance|
      config << { 
        :customer => deployed_instance.customer.name,
        :app      => deployed_instance.app.name,
        :instance => deployed_instance.name,
        :services => services_by_instance[deployed_instance].collect(&:configuration_hash),
      }
      config
    end
  end
  
  def puppet_manifest
    instances.inject('') { |buffer, instance| buffer += instance.puppet_manifest }
  end
  
  def safe_to_delete?
    all_deployed_services.blank?
  end
end
