# CKAN setup for Google Cloud Platform (GCP)

## Setup CKAN for GCP

To setup CKAN for Google Cloud Platform (GCP), clone [CKAN](https://github.com/ckan/ckan) and run [setup_ckan.sh](setup_ckan.sh) with as arguments the path to the setup folder and the path to your CKAN folder. For example:
```setup_ckan.sh path/to/setup path/to/ckan```.

**Note:** The files ending on ```-diff``` are files based on tag 
[ckan-2.9.2](https://github.com/ckan/ckan/tree/ckan-2.9.2). When updating CKAN, it is possible
that [setup_ckan.sh](setup_ckan.sh) does not work completely anymore but in the ```-diff```
files you can see the changes made to the files to make CKAN run with GCP and or with the 
[extensions](ckan/ckan-extensions).

**Note:** If you are installing via the [google-cloud-init.yml](ckan/docker-GCP/cloud-compute-instance/google-cloud-init.yml),
then CKAN is cloned in this file. Cloning is only necessary when running locally without
[google-cloud-init.yml](ckan/docker-GCP/cloud-compute-instance/google-cloud-init.yml).

### Steps in CKAN installation folder
1. Generate a solr password in the solr folder in the ```contrib/docker-GCP``` folder
2. Copy .env.template to .env in the ```contrib/docker-GCP``` folder and fill in the missing values
3. Download key of the GCP Service Account that has access to the SQL database and save it as 
```credentials.json``` in the ```contrib/docker-GCP``` folder
4. Navigate to ```contrib/docker-GCP``` or ```contrib/docker``` and run ```docker-compose up --build```.

## Additions

Locally, this CKAN setup makes sure that an SQL database from Google Cloud Platform (GCP) can be used as database.  
Also, using the [cloud-compute-instance](ckan/docker-GCP/cloud-compute-instance) folder, GCP Compute Engine can be
used to setup CKAN on GCP.
Furthermore, [oauth2 authentication](https://github.com/conwetlab/ckanext-oauth2) is added
together with the
[rule](ckan/ckan-extensions/ckanext-viewerpermissions)
that only authenticated users can see certain datasets, the addition
of a [custom VWT vocabulary](ckan/ckan-extensions/ckanext-custom_vocabulary) and a 
[custom VWT theme](ckan/ckan-extensions/ckanext-vwt_theme).

## Local Installation

To run this CKAN setup locally, use the [CKAN installation instructions
for Docker
compose](https://docs.ckan.org/en/2.8/maintaining/installing/install-from-docker-compose.html)
in the folder ```contrib/docker```
if you want to run it with a local database.  
Or in the folder ```contrib/docker-GCP```
if you want to run it with a [Google Cloud Platform
(GCP)](https://cloud.google.com) database. 
If you want to run it with a nginx instance, copy the [Docker-compose
file](ckan/docker-GCP/cloud-compute-instance/docker-compose.yml)
into ```contrib/docker-GCP``` and replace the ```cloudsql-proxy``` part with the original
```docker-compose.yml``` ```cloudsql-proxy``` part because the credentials file
is needed. Also set ```CKAN_SITE_URL``` to
```https://localhost:443``` in ```contrib/docker-GCP/.env```.

Furthermore make sure that the 'port' variable in
```ckan/config/deployment.ini_tmpl```
is set to the right port (probably 5000 when running locally and using
Google Compute Engine and 8080 when using Cloud Run).

If you want to run CKAN with GCP settings, set the 'GCP' variable in the
[Dockerfile](ckan/Dockerfile)
to 'yes'.

## Google Cloud Platform Cloud Run Installation

To run this CKAN setup on [Google Cloud Platform (GCP) Cloud
Run](https://cloud.google.com/run) build the container image via the Dockerfile in
```ckan/Dockerfile``` and push it to GCP. For more information see [Build Using
Dockerfile](https://cloud.google.com/cloud-build/docs/quickstart-build#build_using_dockerfile).
Do not forget to add the environment variables.

## Google Cloud Platform Compute Engine Installation

To run this CKAN setup on [Google Cloud Platform (GCP) Compute
Engine](https://cloud.google.com/compute) first create a network and
then create firewall-rules on this network to open access to the ssl
port and, if you want, the ssh port. Then create the compute instance,
for more information see [gcloud compute instance
create](https://cloud.google.com/sdk/gcloud/reference/compute/instances/create).
The
[google-cloud-init.yml](ckan/docker-GCP/cloud-compute-instance/google-cloud-init.yml)
should be used as the user-data in the metadata-from-file parameter.
Nginx also needs ssl certificates, these are made via
google-cloud-init.yml but this does need a .cnf file, see [How to create
a CSR with
OpenSSL](https://www.switch.ch/pki/manage/request/csr-openssl/) for more
information about creating such a file.

## Nginx

It is also possible to run this CKAN setup with
[Nginx](https://www.nginx.com/). If you want to run it with a nginx instance, 
copy the [Docker-compose
file](ckan/docker-GCP/cloud-compute-instance/docker-compose.yml)
into ```contrib/docker-GCP``` and replace the ```cloudsql-proxy``` part with the original
```docker-compose.yml``` ```cloudsql-proxy``` part because the credentials file
is needed locally but not on GCP. Also set ```CKAN_SITE_URL``` to
```https://localhost:443``` in ```contrib/docker-GCP/.env```.
Furthermore, you will need a ```ssl-certs``` folder in the ```contrib/docker-GCP```
folder. This file should contain the files ```ckan-ssl.cnf```, ```ckan-ssl.crt``` 
and ```ckan-ssl.key```. See [How to create
a CSR with
OpenSSL](https://www.switch.ch/pki/manage/request/csr-openssl/) for more
information about creating a .cnf file and with it the .crt and .key files.

## Environment Variables

The following environment variables need to be set. See the github of
[ckanext-oauth2](https://github.com/conwetlab/ckanext-oauth2/wiki/Activating-and-Installing)
for more information. If you are using Cloud Run, these variables have
to be added as environment variables when deploying the image to GCP. If
you are using Cloud Engine, these variables have to be added as metadata
when creating the engine. The [google-cloud-init
file](ckan/docker-GCP/cloud-compute-instance/google-cloud-init.yml)
shows what the names of these variables should be. If you are running
CKAN locally, only the .env file is needed, it can be made by copying
the
[.env.template](ckan/docker-GCP/.env.template)
file, renaming it to .env and filling in the missing values.

**Locally:** in the .env file in contrib/docker: 
~~~
CKAN_SOLR_PASSWORD
SOLR_PORT CKAN_SOLR_URL CKAN_OAUTH2_AUTHORIZATION_ENDPOINT
CKAN_OAUTH2_TOKEN_ENDPOINT CKAN_OAUTH2_CLIENT_ID
CKAN_OAUTH2_CLIENT_SECRET CKAN_OAUTH2__SCOPE
CKAN_OAUTH2_PROFILE_API_URL CKAN_OAUTH2_PROFILE_API_USER_FIELD
CKAN_OAUTH2_PROFILE_API_MAIL_FIELD OAUTHLIB_INSECURE_TRANSPORT
OAUTHLIB_RELAX_TOKEN_SCOPE CKAN_PRIVATE_ORGS
~~~

Where ```CKAN_PRIVATE_ORGS``` are the organisations in CKAN that have
datasets that should only be visible to authenticated users.
~~~
CKAN_PRIVATE_ORGS=organisation1,organisation2,etcetera
~~~

**Note:** Organisations are being segregated by a comma (',').

**Note:** When using GCP, make sure that ```CKAN_SOLR_PASSWORD``` is the
unhashed password of
[security.json](https://lucene.apache.org/solr/guide/6_6/basic-authentication-plugin.html).
Security.json should be placed in contrib/docker-GCP/solr. To change
SOLR's password, the file
[solr_generate_pass.py](ckan/docker-GCP/solr/solr_generate_pass.py)
can be used.

**Note:** When running locally, make sure that the generated password is
set as the solr password in the .env file.

**GCP Cloud Run:** Only the following two values do not have to be
added, unless running locally:
~~~
SOLR_PORT 
CKAN_SOLR_URL
~~~

**GCP Cloud Run + Locally:** The rest of the values that have to be
added to the .env file above have to be added as environment variables
to the Docker image. With addition:
~~~
CKAN_SQLALCHEMY_URL=postgresql://{GCP_DATABASE_USER}:[{GCP_DATABASE_PASSWORD}@/{GCP_DATABASE_NAME}?host=/cloudsql/{GCP_INSTANCE](mailto:{GCP_DATABASE_PASSWORD}@/{GCP_DATABASE_NAME}?host=/cloudsql/{GCP_INSTANCE)}
~~~

**Note:** the following also needs to be added to the .env file in
```contrib/docker-GCP``` when wanting to run that one locally.
~~~
GCP_SQL_INSTANCE
~~~

**GCP Compute Engine:** All the necessary variables for the Compute
Engine can be found in the [google-cloud-init
file](ckan/docker-GCP/cloud-compute-instance/google-cloud-init.yml).
Note that this file also makes the .env file. When using nginx, the
```OAUTHLIB_INSECURE_TRANSPORT``` variable can be set to false.

## Updating CKAN

When updating CKAN, note that there are [stable
versions](https://github.com/ckan/ckan/releases). The [master
branch](https://github.com/ckan/ckan) can be unstable.

**Note:** The files ending on ```-diff``` are files based on tag 
[ckan-2.9.2](https://github.com/ckan/ckan/tree/ckan-2.9.2). When updating CKAN, it is possible
that [setup_ckan.sh](setup_ckan.sh) does not work completely anymore but in the ```-diff```
files you can see the changes made to the files to make CKAN run with GCP and or with the 
[extensions](ckan/ckan-extensions).
