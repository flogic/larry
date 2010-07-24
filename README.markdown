## Larry -- the first name in configuration ##

Currently this is mostly an ongoing experiment in solving our high-level customer/application deployment management issues.

### History ###

This project was born out of our original implementation of the Puppet-Dashboard (now fully owned by Puppet Labs and on github at [http://github.com/reductivelabs/puppet-dashboard](http://github.com/reductivelabs/puppet-dashboard)).

We built the original implementation of the Puppet dashboard and a Puppet reporting tool, which was also ultimately merged into the dashboard.  Having spent over a year discussing with Luke various add-on tools to make Puppet more useful to large installations, I (Rick) finally had a domain modeling breakthrough which clarified for me a lot of the concepts and relationships necessary to make the "dashboard" useful.  Since the modeling breakthrough came as part of trying to make Puppet more useful for our company (O.G. Consulting) in our customer cloud hosting business, the model insights were especially relevant to how we view our business.  I applied an implementation of those models to the existing dashboard work we had done.  Puppet Labs isn't currently working in our domain (or at least their large customers do not appear to be, which is the important factor), and the additional modeling work was more useful to us than them.

So, we rolled back the changesets to the point where the models were in line with the functionality they needed and forked the project.  Puppet-dashboard includes the line of development up to the fork point and further on once the code began to be maintained by the excellent team at Puppet Labs (as well as their merging in of the Puppet reporting tool).  Larry is the line of development we had originally executed past the fork point including the higher-level customer models we use to manage our cloud hosting business.

### Motivation ###

In our hosting business we support a number of customers over time.  Each of those customers will have some number of applications hosted with us (we primarily host those application which we have done active custom development on).  Each of those applications will have some number of configuration instances (e.g., a production instance, a staging instance, a QA instance, etc.).  Any instance can be deployed to some number of hosts.  An application can be deployed some number of times even to the same host (the instance varying).  Any instance relies upon some set of services which must be installed properly for the instance to function properly.  Instances can be deployed using different configurations over time.  We should be able to deploy an instance to a host using a given configuration while deploying to another host using another configuration (e.g., to test that an upgraded configuration will work as expected).  We want to be able to specify the time periods when an instance will be deployed to a host using a certain configuration, and not have to make manual changes at the time of deployment.  Using a tool like puppet, Larry can act as an external nodes classifier, meaning that the tool contacts Larry for the configuration at a given point in time and Larry delivers the complete correct configuration for that time.

Clearly tools like puppet will be the "last mile" and handle the heavy lifting of applying timely configurations across networks of hosts.  The puppet-dashboard model of allowing remote configuration of groups of nodes with classes and parameters is useful and will probably suit many (or most) installations.  We find that model lacking for the domain in which we work.  We need to organize deployments by customer and application, orthogonal to the services and host groups where they might be found running.  For example, billing tools should be able to consult Larry and determine the amounts to bill customers.  Conversely, tools can query an invoicing tool (e.g., we use freshbooks) and authorize or fail to reauthorize hosting services for an application or an entire customer automatically on payment or failure to pay.  Perhaps some of the concepts being fielded in Larry will find utility in later versions of the Puppet toolchain.

In a different direction, Larry is also concerned with services which are *about* other services in a system.  For example, every time a web application is deployed with a database, proper management of a number of other services is necessary:

 * database backups should be configured and scheduled
 * log rotation and compression should happen on a regular basis
 * systems monitoring (nagios, monit, etc.) should be configured and enabled
 * firewall ports should be opened

Some of these services may occur on the same host where the instance is deployed, but they often will be deployed to other hosts on the network.  These services should be disabled before the normal services for the deployed instance are disabled.  They should be enabled only after the normal services for the deployed instance are successfully enabled.  Using a proper domain model, these are services, participating in a service dependency graph just like all other known services.  But, unlike other services they have an *aboutness* as related to the instance being deployed.  The Larry model lets us say things like "this instance is a Rails app, whatever that currently means", and it also allows us to say "and every Rails app gets a database backup, nagios monitoring, log rotation, etc."

There is a subtle and difficult problem in determining where the role of the Puppet (e.g.) manifest and class author stops and where the role of the external classification tool begins.  We believe a tool such as Larry benefits from having high-granularity visibility into the graph of "classes" (Puppet term) or "services" (Larry term) that an instance of an application requires.  Below that level of granularity, a well-maintained and modular class library is critical to deploying that configuration to a host.  As we move forward we hope to define that boundary, for highly tuned usage models, even more clearly.

Ultimately, even though it is historically connected closely to Puppet, Larry is agnostic about the end tool which operates on the configuration information it maintains.  It intends to support Puppet directly, as the authors of Larry see Puppet as the only configuration management tool which has modeled the domain even remotely correctly.  The resource graph approach provides differences-in-kind advantages over direct scripted approaches without such a model.  Regardless, the information deliverable from Larry should be usable even by a directory of shell scripts, properly assembled.

### Obligatory model diagram ###

<a href="http://github.com/flogic/larry/raw/master/doc/domain-model-small.png"><img src="http://github.com/flogic/larry/raw/master/doc/domain-model-small.png" width="480" height="380"></a>
<br/>
<a href="http://github.com/flogic/larry/raw/master/doc/domain-model-small.png">(or click here)</a>

### Status ###

#### Capabilities ####

 * can configure customers, applications, instances, service graphs, hosts, deployment snapshots, and can create deployments
 * supports puppet, json, and yml host configuration exports (via REST)
 * time-based deployments work properly
 * front-end is automatically timezone aware and presents time data in local timezone for the user (more important than I originally thought :-)

#### Shortcomings ####

 * the delivered Puppet manifest almost certainly will not work
 * currently have not implemented the "audits" functionality (services *about* other services)
 * almost no work has been done with our systems team (Websages, Inc.) on "meeting in the middle" with their growing collection of Puppet manifests
 * very very weakly tested in real-world configurations
 * no authentication framework in place
 * cannot currently stop a deployment from the front-end
