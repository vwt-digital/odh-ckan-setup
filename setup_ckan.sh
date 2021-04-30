#!/bin/bash

set_env_files(){
    ###########################
    # Set environment variables in .env files
    ###########################
    echo "Add to .env files"

    # Make sure that the .env.template contains the right variables for the extensions
    cat << EOF >> "${_CKAN_INSTALLATION_PATH}"/contrib/docker/.env.template
#
# Add the right values for the variables below
# OAUTH2 settings
CKAN_OAUTH2_AUTHORIZATION_ENDPOINT=https://YOUR_OAUTH_SERVICE/authorize
CKAN_OAUTH2_TOKEN_ENDPOINT=https://YOUR_OAUTH_SERVICE/token
CKAN_OAUTH2_CLIENT_ID=YOUR_CLIENT_ID
CKAN_OAUTH2_CLIENT_SECRET=YOUR_CLIENT_SECRET
CKAN_OAUTH2_SCOPE=profile other.scope
CKAN_OAUTH2_PROFILE_API_URL=https://YOUR_OAUTH_SERVICE/user
CKAN_OAUTH2_PROFILE_API_USER_FIELD=username
CKAN_OAUTH2_PROFILE_API_MAIL_FIELD=email
OAUTHLIB_INSECURE_TRANSPORT=False
OAUTHLIB_RELAX_TOKEN_SCOPE=False
# custom viewerpermissions extension settings
CKAN_PRIVATE_ORGS=ORGANISATION1,ORGANISATION2" >>
EOF

    # Make sure that the .env.template contains the right variables
    cat << EOF >> "${_CKAN_INSTALLATION_PATH}"/contrib/docker-GCP/.env.template
#
# Add the right values for the variables below
# GCP sql url
CKAN_SQLALCHEMY_URL=postgresql://GCP_SQL_DATABASE_USER:GCP_SQL_DATABASE_PASSWORD@cloudsql-proxy/GCP_SQL_DATABASE_NAME
GCP_SQL_INSTANCE=YOUR_GCP_SQL_INSTANCE
# OAUTH2 settings
CKAN_OAUTH2_AUTHORIZATION_ENDPOINT=https://YOUR_OAUTH_SERVICE/authorize
CKAN_OAUTH2_TOKEN_ENDPOINT=https://YOUR_OAUTH_SERVICE/token
CKAN_OAUTH2_CLIENT_ID=YOUR_CLIENT_ID
CKAN_OAUTH2_CLIENT_SECRET=YOUR_CLIENT_SECRET
CKAN_OAUTH2_SCOPE=profile other.scope
CKAN_OAUTH2_PROFILE_API_URL=https://YOUR_OAUTH_SERVICE/user
CKAN_OAUTH2_PROFILE_API_USER_FIELD=username
CKAN_OAUTH2_PROFILE_API_MAIL_FIELD=email
OAUTHLIB_INSECURE_TRANSPORT=False
OAUTHLIB_RELAX_TOKEN_SCOPE=False
# custom viewerpermissions extension settings
CKAN_PRIVATE_ORGS=ORGANISATION1,ORGANISATION2
# SOLR settings
CKAN_SOLR_USER=solr
CKAN_SOLR_PASSWORD=solr_password
SOLR_PORT=8983
CKAN_SOLR_URL=http://127.0.0.1:8983/solr"
EOF
}

_CKAN_SETUP_PATH=$1

if [ -z "${_CKAN_SETUP_PATH}" ]
then
    echo "This script requires as first argument the path to the folder where the setup files are."
    exit 1
fi

_CKAN_INSTALLATION_PATH=$2

if [ -z "$_CKAN_INSTALLATION_PATH" ]
then
    echo "This script requires as its second argument the path to the folder where CKAN resides."
    exit 1
fi

###########################
# Copy files
###########################

echo "Copy files"

# Copy custom CKAN extensions to CKAN
cp -r "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/ckan-extensions/ckanext-custom_vocabulary "${_CKAN_INSTALLATION_PATH}"/ckanext &&
cp -r "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/ckan-extensions/ckanext-viewerpermissions "${_CKAN_INSTALLATION_PATH}"/ckanext &&
cp -r "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/ckan-extensions/ckanext-vwt_theme "${_CKAN_INSTALLATION_PATH}"/ckanext &&

# Copy VWT Digital logo
cp "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/ODH_logo_original.png "${_CKAN_INSTALLATION_PATH}"/ckan/public/base/images &&

# Copy docker folder in installation to setup docker-GCP folder
cp -r "${_CKAN_INSTALLATION_PATH}"/contrib/docker "${_CKAN_INSTALLATION_PATH}"/contrib/docker-GCP &&

# Copy cloud-compute-instance folder from where the GCP Virtual Machine can be setup
cp -r "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/docker-GCP/cloud-compute-instance "${_CKAN_INSTALLATION_PATH}"/contrib/docker-GCP &&

# Copy the file that generates a SOLR password
cp "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/docker-GCP/solr/solr_generate_pass.py "${_CKAN_INSTALLATION_PATH}"/contrib/docker-GCP/solr/solr_generate_pass.py &&

###########################
# Patch general files
############
# The additions below make sure that the CKAN extensions can be used
###########################

echo "Patch general files" &&

# Patch deployment.ini to use right plugins (CKAN extensions) and to contain the right variables for later setup
patch "${_CKAN_INSTALLATION_PATH}"/ckan/config/deployment.ini_tmpl "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/deployment-ini-tmpl.patch &&

# Patch Dockerfile so that extensions are installed
# With the file, it is assumed that GCP entities are used, if you do not want that you can set the "GCP" variable to False
patch "${_CKAN_INSTALLATION_PATH}"/Dockerfile "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/dockerfile.patch &&

# Patch environment file to set right variables for OAUTH2 extension and custom viewerpermissions extension
patch "${_CKAN_INSTALLATION_PATH}"/ckan/config/environment.py "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/environment.patch &&

###########################
# Patch CKAN docker folder
############
# The additions below make sure that the CKAN extensions can be used
###########################

echo "Patch CKAN docker folder" &&

# Patch ckan-entrypoint to contain right variables for OAUTH2 extension and custom viewerpermissions extension
patch "${_CKAN_INSTALLATION_PATH}"/contrib/docker/ckan-entrypoint.sh "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/docker-GCP/ckan-entrypoint.patch &&


# Patch docker-compose to contain right variables for OAUTH2 extension and custom viewerpermissions extension
patch "${_CKAN_INSTALLATION_PATH}"/contrib/docker/docker-compose.yml "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/docker-GCP/docker-compose.patch &&

###########################
# Create CKAN Google Cloud Platform (GCP) folder
############
# The additions below create a CKAN GCP folder
# This creates the opportunity to use a GCP SQL database locally
# It also makes sure that CKAN can run on GCP
###########################

echo "Create CKAN GCP folder" &&

# Patch entrypoint to setup right environment variables for OAUTH2 extension and custom viewerpermissions extension
# Also remove the while loop that checks if the database is ready, this does not work on GCP because
# the CloudSQL proxy starts up a couple of times but it does work
# Furthermore remove the need for the datapusher URL variable to be present
# And add rebuilding of database
patch "${_CKAN_INSTALLATION_PATH}"/contrib/docker-GCP/ckan-entrypoint.sh "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/docker-GCP/ckan-entrypoint.patch &&

# Patch Nginx configuration so that it can be used by the VM on GCP as defined in the cloud-compute-instance folder
patch "${_CKAN_INSTALLATION_PATH}"/contrib/docker-GCP/nginx.conf "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/docker-GCP/nginx.patch &&

# Patch docker-compose file to use right environment variables for GCP access
# Also add environment variables for OAUTH2 extension and custom viewerpermissions extension
# And use Cloudsql-proxy instead of local database
# Note: this is not the docker-compose used by the VM on GCP, it is the docker-compose that you can use to locally
#       set up CKAN with a Cloudsql-proxy. The docker-compose used on GCP is in the folder "cloud-compute-instance"
patch "${_CKAN_INSTALLATION_PATH}"/contrib/docker-GCP/docker-compose.yml "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/docker-GCP/docker-compose.patch &&

# Patch SOLR folder to use the generated SOLR password
patch "${_CKAN_INSTALLATION_PATH}"/contrib/docker-GCP/solr/Dockerfile "${_CKAN_SETUP_PATH}"/ckan/patch_and_copy/docker-GCP/solr/dockerfile-solr.patch &&

# Set .env files
set_env_files ||
echo "ERROR: Setting CKAN up with GCP failed" && exit 1
