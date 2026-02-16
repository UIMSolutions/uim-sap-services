Feature Scope Description | PUBLIC
2023-07-17
1 About This Document. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .3
2 Platform Features. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .4
2.1 Account Administration. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
2.2 Connectivity, Extensibility, Integration. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
2.3 Security. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .6
2.4 Runtimes. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8
2.5 Services. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8
3 Product Availability. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .12
4 Compliance and Security. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 13
5 Service Level Agreement. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14
6 Browser Support. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 15
2 PUBLIC
Feature Scope Description for SAP BTP, Neo Environment
Content
1 About This Document
Read this document for a high-level summary of the core platform features available for the SAP BTP, Neo
environment .
This document describes the features that are available in the SAP BTP, Neo environment . The availability of
some of them may depend on your license agreement with SAP.
To illustrate integration with other SAP offerings, the product documentation on SAP Help Portal might
include references to features that are not included with the SAP BTP, Neo environment . Features that are not
included in this feature scope description might require a separate license.
 Note
This document does not include any information about:
• Beta features. Beta features are described in the documentation on SAP Help Portal.
• Packages and pricing. For more information, see SAP Extension Suite - Pricing and SAP Integration
Suite - Pricing .
Feature Scope Description for SAP BTP, Neo Environment
About This Document PUBLIC 3
2 Platform Features
Get a high-level overview about the features and capabilities of the SAP BTP, Neo environment.
The SAP BTP, Neo environment provides comprehensive application development services and capabilities
that let you develop new cloud applications, extend existing on-premise and cloud solutions, and integrate
applications in the cloud.
 Note
Features of services that are separately licensed are described in the service-specific feature scope
descriptions linked from the service pages in the SAP Discovery Center - Service Catalog.
For an overview of all available services and their features, see SAP Discovery Center - Service Catalog.
The SAP BTP, Neo environment comes with a set of developer and administration tools that enable you to use
the following features:
2.1 Account Administration
Use different user interfaces to operate your accounts.
Account Administration
Feature Description
Manage your accounts using different user interfaces. Work with the
web-based user
interface
Perform account operations using the
web-based administration user inter
face.
Work with the
command-line
tool
Perform account operations using the
command-line interface.
Work with APIs Manage, monitor, and automate ac
count operations using REST APIs.
4 PUBLIC
Feature Scope Description for SAP BTP, Neo Environment
Platform Features
Feature Description
Set up and manage your account model. Manage with di
rectories and
subaccounts
Use subaccounts to deploy applications,
use services, and manage your subscrip
tions. Structure your global account by
subaccounts according to organizational
and project requirements. Optionally, or
ganize subaccounts into directories to
suit technical and business needs.
Manage deploy
ments across
different regions
Choose between different infrastructure
providers and regions when creating
new subaccounts.
Organize and fil-
ter directories
and subac
counts
Label or tag your directories and subac
counts using custom properties accord
ing to your own business and technical
needs.
Manage entitlements and quotas. Manage enti
tlements and
quota
Manage the assignments of product enti
tlements and quotas from your global ac
count to any of your directories and sub
accounts.
Manage remote resources. Manage serv
ice provider
resources
Connect to provider accounts of a non-
SAP cloud vendor and consume remote
service resources that you already own,
and that are supported.
Manage users. Manage users on global ac
count, directory, and subac
count level
Add users as account mem
bers and manage their au
thorizations.
Monitor usage information and costs. Monitor us
age and con
sumption
costs
Gather, store, and make usage information
available for all services and applications in
all regions in a cloud deployment, for the
purpose of central analysis, reporting, and
license auditing.
View usage
analytics
Explore, compare, and analyze usage infor
mation for the services and applications
that are available in your global accounts,
directories, and subaccounts.
Work with
APIs
Generate reports based on the resource and
cost consumption within your accounts us
ing REST APIs.
Manage application subscriptions. Subscribe to appli
cations
Subscribe your subaccounts to mul
titenant applications.
Feature Scope Description for SAP BTP, Neo Environment
Platform Features PUBLIC 5
2.2 Connectivity, Extensibility, Integration
Facilitate integration with on-premise systems running software from SAP and other vendors.
Connectivitiy, Extensibility, Integration
Feature Description
Connectivity between cloud applications and on-premise
systems.
Access on-
premise sys
tems
Easier, faster deployment of hybrid sol
utions compared to traditional reverse
proxy approaches with no firewall configu-
ration changes.
Choose from
multiple sup
ported proto
cols
Access HTTP and RFC protocols for cloud
to on-premise communication and JDBC/
ODBC for communication with cloud data
bases.
Access cloud
databases via
JDBC/ODBC
Access your cloud databases as if they're
running locally in your network, using your
existing database or replication tools.
Propagate
cloud user
identity
Enable users to log on to on-premise sys
tems without providing a password, by
forwarding their logged-on identity from
the cloud.
 Note
For additional and separately licensed integration offerings, see SAP Discovery Center - Service Catalog.
2.3 Security
Support the security policies of your organization.
Security
Feature Description
Manage applica
tion authoriza
tions and
trusted connec
tions to identity
providers.
Use your corporate or
a default IdP Enable user management for your applications by handling authentication to
an external identity provider. Start with SAP ID service as a pre-configured
easy-to-use identity provider. Switch to your corporate identity provider for
customized user management.
Enable role-based ac
cess to applications Enable different privileges to users accessing your applications based on roles.
6 PUBLIC
Feature Scope Description for SAP BTP, Neo Environment
Platform Features
Feature Description
Manage crypto
graphic keys and
certificates.
Manage keystores Use the service as a repository for keystores. Easily retrieve keystores and use
them in various cryptographic operations, such as signing and verifying of digital
signatures, encrypting anddecrypting messages, and performing SSL communi
cation.
Enable client cer
tificate authentica
tion
Enable the standard authentication method in Java EE using a client certificate.
Enable strong en
cryption Use encryption with unlimited strength by installing Java Cryptography Extension
(JCE) unlimited strength jurisdiction policy files on SAP JVM.
Protect applica
tions and APIs
with OAuth 2.0.
Protection of cloud applications based on the OAuth 2.0 protocol based on the IETF RFC 6749 in the Neo
environment
Enables a user to delegate access to an OAuth resource server without the user having to grant its
credentials to the application
Provides an OAuth API and configuration UIs for managing OAuth clients and scopes
Use your user
base from your
Identity Authen
tication tenant
for admin tasks.
Аccess your
subaccount. Use your Identity Authentication tenant as an identity provider for accessing your
subaccount in the Neo environment. In the cloud cockpit and console client, users will
log in using the name and credentials defined in the Identity Authentication tenant.
Configure
your subac
count.
Configure security scenarios such as two-factor authentication, integration with an
on-premise user store, integration with a social corporate provider, and so on. You
enable those scenarios for login using the cloud cockpit or console client.
 Note
For additional and separately licensed security offerings, see SAP Discovery Center - Service Catalog.
Feature Scope Description for SAP BTP, Neo Environment
Platform Features PUBLIC 7
2.4 Runtimes
Build applications using different runtimes, technologies, and tools.
Feature Description
Use Java servers
as virtualized re
sources for your
applications in
the platform.
 Note
Separately
licensed
Manage your Java server
size Choose between different sizes of Java servers with a predefined CPU and
memory to meet your application’s needs.
Manage application life
cycle Start, stop, scale, and configure Java applications using standard tools, our
cockpit and DevOps capabilities.
Execute Java Web appli
cations Develop and run Java Web applications based on standard JSR APIs, and
third-party Java libraries and frameworks that support these standards.
Use Apache Tomcat and
standard Java APIs Leverage different services and Java APIs. Benefit from the Apache Tomcat
runtimes.
HTML5 Applica
tion Runtime
Manage and run
HTML5 applica
tions
Manage and run lightweight HTML5 applications, with simple user experience and
secure connection to on premise and on-demand backend services. HTML5 is a
service deployed as a Java application running in the SAP BTP, Neo environment.
2.5 Services
The following services are part of the overall SAP BTP contract.
Services
Feature Description
Store and ver
sion source code
in Git reposito
ries.
Records differences
between versions Only the differences between versions are recorded allowing for a compact
storage and efficient transport.
Cost-effective and
simple Create and merge branches supporting a multitude of development styles. Git is
widely used and supported by many tools and is highly distributed. A clone of a
repository contains the complete version history.
Operations on local
repository clone Perform almost all operations locally and thus very fast and without need to be
permanently online. Only required when synchronizing with the Git service.
Debug Java ap
plications
Debug on demand Start and stop debugging without having to restart the application or SAP JVM.
Debug remotely Debug applications running remotely, even over networks with high latency.
8 PUBLIC
Feature Scope Description for SAP BTP, Neo Environment
Platform Features
Feature Description
Activate the Dy
natrace Agent
for Java applica
tions
 Note
You need a
license for a
Dynatrace
SaaS moni
toring envi
ronment to
be able to
use this fea
ture.
Connect Applications
to Dynatrace Bind the Java applications in your subaccount to an existing Dynatrace SaaS
monitoring environment to monitor your workload.
Activate Monitoring
Data Collection Enable the collection of monitoring data for Java applications running on SAP
BTP, including metrics, events, and end-to-end traces, by binding the applica
tions to Dynatrace.
Configure Application
Parameters Prepare your applications for Dynatrace and customize tags or process group
IDs of your Java processes using JVM arguments.
Manage the life
cycle of Java ap
plications by us
ing a REST API.
Obtain a CSRF token Use a Lifecycle Management REST API call to obtain a Cross-Site Request
Forgery (CSRF) token. This token is obligatory for performing all other REST API
calls related to the lifecycle management of Java applications.
Create applications Use a Lifecycle Management REST API call to create and persist a Java applica
tion.
List applications Use a Lifecycle Management REST API call to get a list with the currently availa
ble Java applications.
Read, update, de
lete, patch applica
tions
Use the corresponding Lifecycle Management REST API call to read, update,
delete, or patch a Java application.
Read or update an
application state Use the corresponding Lifecycle Management REST API call to read or update
the current state of a Java application.
List, create, or up
date binaries Use the corresponding Lifecycle Management REST API call to list, create, or
update multiple binaries of a Java application as part of the deployment and
redeployment scenarios.
Read or update the
state of a process Use a Lifecycle Management REST API call to read or update the state of a Java
application process.
Profile Java ap
plications that
run on the cloud
platform.
Profile applications Profile Java applications running on a cloud-based SAP JVM.
Review profiling data Review the profiling data using statistics and snapshots.
Feature Scope Description for SAP BTP, Neo Environment
Platform Features PUBLIC 9
Feature Description
Manage moni
toring data and
configure alert
notifications.
Fetch application
metrics Use the SAP BTP cockpit or the Metrics REST API to get the status of or the
metrics from a Java app and its processes, HANA XS app, or HTML5 app.
Fetch metrics of a
database system Use the SAP BTP cockpit or the Metrics REST API to get the metrics of a
selected database system to get information about its health state.
View history of met
rics Use the SAP BTP cockpit to see the history of metrics for a Java, HTML5, or
HANA XS application, or for a database system.
Register availability
checks Use the SAP BTP cockpit, the console client, or the Checks REST API to retrieve
or configure availability checks for Java or SAP HANA XS applications.
Set Alert Email
Channel Configure e-mail alert notifications for an application or for all applications and
database systems in a subaccount.
Set Alert Webhook
Channel Use SAP BTP cockpit or Alerting Channels REST API to configure an alert web
hook channel to receive alert notifications.
Configure JMX-
based checks Use the SAP BTP cockpit, the console client, or the Checks REST API to retrieve
or configure JMX checks for Java applications.
Perform JMX opera
tions Use the SAP BTP cockpit to execute operations on JMX MBeans to monitor and
manage the performance of the JVM and your Java applications.
Register custom
checks Use the SAP BTP cockpit or the Checks REST API to retrieve or configure
custom HTTP checks for an HTML5 or SAP HANA XS application.
Override thresholds
of a default check Use the Checks REST API to override the thresholds for a default check of a Java
application.
Configure log
ging and specify
log level mes
sages.
Configure loggers for Java
applications Configure loggers through the SAP BTP cockpit or the console client to
produce logs for Java applications.
Configure log level and
types of logs Configure a log level when configuring loggers.
Configure a log channel Configure a log channel to receive logs per a subaccount with the Log
Channels API.
Retrieve logs Retrieve default trace, HTTP access, and garbage collection logs via the
console client, SAP BTP cockpit, and Logs API.
Generate heap and thread
dumps Generate heap and thread dumps to analyze the performance of a Java
process via the SAP BTP cockpit.
Use retention period Do a postmortem analysis during this period, if needed.
10 PUBLIC
Feature Scope Description for SAP BTP, Neo Environment
Platform Features
Feature Description
Deploy, sub
scribe, and
transport solu
tions using Mul
titarget applica
tions (MTAs)
Deploying
Solutions You provision a Solution by deploying it using a Multitarget Application archive as the
Solution carrier. A Solution can be deployed using the cockpit, through the SAP Cloud
Platform Command Client, or the Change and Transport System (CTS+) tool.
Updating Sol
utions You update your Solution using the cockpit, in order to enhance it with new capabilities
or technical improvements. This can also be done using the respective SAP Business
Technology Platform Command Client command.
Monitoring
Solutions Via the Solutions view in your subaccount you can monitor the state of the individ
ual components of a given Solution, licenses and subscribers. Monitoring operations
can also be executed using SAP Business Technology Platform Command Client com
mands.
Deleting Sol
utions You can remove a Solution using either the cockpit or the SAP Business Technology
Platform Command Client. Note that various Solution components that might be inter
connected with external resources are not removed.
Subscribing
to Multiten
ant Solutions
You can use a multitenant Solution provided by another subaccount by subscribing to
it. You can do so using the Solutions view, if you have been granted an entitlement from
the Solution provider.
 Note
Services that are separately licensed are described in the service-specific feature scope descriptions linked
from the service pages in the SAP Discovery Center - Service Catalog.
For an overview of all available services and their features, see SAP Discovery Center - Service Catalog.
Feature Scope Description for SAP BTP, Neo Environment
Platform Features PUBLIC 11
3 Product Availability
This section describes the product availability aspects.
Availability Aspect Description
Platform availability • Latency: network latency depends on various factors, no precise information can be provided
on a general level
• Resilience: system can regain stable state after disruption
• Scalability: system responds to peaks in resource requirements
For more information on availability, see SAP Trust Center Agreements Cloud Services
Agreements Service Level Agreement for SAP Cloud Services .
Regions SAP BTP is hosted in different regions. For information on the availability of SAP BTP services
according to region and infrastructure provider, see SAP Discovery Center.
Infrastructures SAP BTP, Neo environment runs in SAP regions.
Languages The central web-based administration user interface for SAP BTP is available in the following
languages:
• Chinese
• English
• Japanese
• Korean
For language availability of other user interfaces refer to the respective detailed feature scope
description.
The related documentation on SAP Help Portal is available in the following languages:
• Chinese
• English
• Japanese
Accessibility SAP BTP provides accessibility support in its administration and development tools, and the
customer documentation. This includes:
• High-contrast black theme for the administration UI
• Texts and information
• UI elements via attributes and element IDs
• Orientation and navigation throughout the UI
• User interaction
For more information, see SAP Trust Center.
12 PUBLIC
Feature Scope Description for SAP BTP, Neo Environment
Product Availability
4 Compliance and Security
SAP BTP environments ensure cloud security at multiple levels.
Certificates and Reports
SAP BTP environments regularly undergo audits and reviews of its policies and controls.
• For the complete list of compliance and security standards that the cloud platform is compliant with, see
SAP Trust Center Compliance and search for SAP Business Technology Platform ISO.
• For the complete list of Service Organizational Control (SOC) audit reports available for the cloud platform,
see SAP Trust Center Compliance and search for SAP Business Technology Platform SOC.
Regions
To learn how SAP data centers are built, operated, and secured, see SAP Trust Center Data Center .
Data Protection
SAP BTP environments follow SAP's global data protection and privacy guidelines. For more information on the
guidelines, see SAP Trust Center Privacy .
To access the Personal Data Processing policy for your region, see SAP Trust Center Agreements Data
processing agreement .
Feature Scope Description for SAP BTP, Neo Environment
Compliance and Security PUBLIC 13
5 Service Level Agreement
The Service Level Agreement (SLA) is a contract between SAP and its customers that forms the basis of your
contractual relationship with SAP when referenced in specific order forms.
• The order form is the ordering document to subscribe to cloud services from SAP. It defines the
commercial terms and lays out the agreement structure. The order form also incorporates several other
documents that relate to the SLA.
See Sample Order Form .
• The Service Level Agreement for SAP Cloud Services applies to any cloud service on the SAP price list,
defining downtime, credits, update windows, and others.
See Service Level Agreement for SAP Cloud Services .
• The SAP Business Technology Platform Supplement overrides the Service Level Agreement for SAP
Cloud Services in case of deviations and specifies the SLA for SAP Business Technology Platform in
general.
For more information, see SAP Business Technology Platform Supplement .
• The SAP Business Technology Platform Service Description Guide provides information on cloud
services from SAP, including any deviations to the SLA for a specific service.
For more information, see SAP Business Technology Platform Service Description Guide .
Additionally, the General Terms and Conditions for SAP Cloud Services warrants the SLA and provides the
available remedy if SAP fails to meet its SLA. For more information, see General Terms and Conditions for SAP
Cloud Services .
Maintenance Windows and Major Upgrade Windows
The maintenance and major upgrade windows are defined in the Service Level Agreement for SAP Cloud
Services. SAP may update these windows from time to time in accordance with the Agreement.
The following windows apply:
Maintenance Windows Major Upgrade Windows
MENA APJ Europe Americas Frequency MENA APJ Europe Americas
Zero down-
time
Zero down-
time
Zero down-
time
Zero down-
time
Up to 4
times per
year
FRI
2 pm (UTC)
(4 hrs)
FRI
10 pm
(UTC)
(4 hrs)
SAT
4 am (UTC)
(4 hrs)
For the latest information, see Maintenance Windows and Major Upgrade Windows for SAP Cloud Services
and search for your service.
14 PUBLIC
Feature Scope Description for SAP BTP, Neo Environment
Service Level Agreement
6 Browser Support
Overview of the browser support
For UIs of the platform itself, such as the web-based administration user interface for SAP BTP, the following
browsers are supported on Microsoft Windows PCs and, where mentioned below, on macOS:
Browser Versions
Google Chrome Latest version
Mozilla Firefox Extended Support Release (ESR) and latest version
Microsoft Edge (chromium-based) Latest Current Branch for Business
Safari Latest two versions (for macOS only)
Feature Scope Description for SAP BTP, Neo Environment
Browser Support PUBLIC 15
Important Disclaimers and Legal Information
Hyperlinks
Some links are classified by an icon and/or a mouseover text. These links provide additional information.
About the icons:
• Links with the icon : You are entering a Web site that is not hosted by SAP. By using such links, you agree (unless expressly stated otherwise in your
agreements with SAP) to this:
• The content of the linked-to site is not SAP documentation. You may not infer any product claims against SAP based on this information.
• SAP does not agree or disagree with the content on the linked-to site, nor does SAP warrant the availability and correctness. SAP shall not be liable for any
damages caused by the use of such content unless damages have been caused by SAP's gross negligence or willful misconduct.
• Links with the icon : You are leaving the documentation for that particular SAP product or service and are entering an SAP-hosted Web site. By using
such links, you agree that (unless expressly stated otherwise in your agreements with SAP) you may not infer any product claims against SAP based on this
information.
Videos Hosted on External Platforms
Some videos may point to third-party video hosting platforms. SAP cannot guarantee the future availability of videos stored on these platforms. Furthermore, any
advertisements or other content hosted on these platforms (for example, suggested videos or by navigating to other videos hosted on the same site), are not within
the control or responsibility of SAP.
Beta and Other Experimental Features
Experimental features are not part of the officially delivered scope that SAP guarantees for future releases. This means that experimental features may be changed by
SAP at any time for any reason without notice. Experimental features are not for productive use. You may not demonstrate, test, examine, evaluate or otherwise use
the experimental features in a live operating environment or with data that has not been sufficiently backed up.
The purpose of experimental features is to get feedback early on, allowing customers and partners to influence the future product accordingly. By providing your
feedback (e.g. in the SAP Community), you accept that intellectual property rights of the contributions or derivative works shall remain the exclusive property of SAP.
Example Code
Any software coding and/or code snippets are examples. They are not for productive use. The example code is only intended to better explain and visualize the syntax
and phrasing rules. SAP does not warrant the correctness and completeness of the example code. SAP shall not be liable for errors or damages caused by the use of
example code unless damages have been caused by SAP's gross negligence or willful misconduct.
Bias-Free Language
SAP supports a culture of diversity and inclusion. Whenever possible, we use unbiased language in our documentation to refer to people of all cultures, ethnicities,
genders, and abilities.
16 PUBLIC
Feature Scope Description for SAP BTP, Neo Environment
Important Disclaimers and Legal Information
Feature Scope Description for SAP BTP, Neo Environment
Important Disclaimers and Legal Information PUBLIC 17
www.sap.com/contactsap
© 2023 SAP SE or an SAP affiliate company. All rights reserved.
No part of this publication may be reproduced or transmitted in any form
or for any purpose without the express permission of SAP SE or an SAP
affiliate company. The information contained herein may be changed
without prior notice.
Some software products marketed by SAP SE and its distributors
contain proprietary software components of other software vendors.
National product specifications may vary.
These materials are provided by SAP SE or an SAP affiliate company for
informational purposes only, without representation or warranty of any
kind, and SAP or its affiliated companies shall not be liable for errors or
omissions with respect to the materials. The only warranties for SAP or
SAP affiliate company products and services are those that are set forth
in the express warranty statements accompanying such products and
services, if any. Nothing herein should be construed as constituting an
additional warranty.
SAP and other SAP products and services mentioned herein as well as
their respective logos are trademarks or registered trademarks of SAP
SE (or an SAP affiliate company) in Germany and other countries. All
other product and service names mentioned are the trademarks of their
respective companies.
Please see https://www.sap.com/about/legal/trademark.html for
additional trademark information and notices.
THE BEST RUN
