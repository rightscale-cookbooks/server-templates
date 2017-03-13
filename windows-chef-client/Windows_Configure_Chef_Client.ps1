# ---
# RightScript Name: Windows Configure Chef Client
# Description: Configure Chef Client
# Inputs:
#   CHEF_CLIENT_VALIDATOR_PEM:
#     Category: CHEF
#     Description: 'Private SSH key which will be used to authenticate the Chef Client
#       on the remote Chef Server. Example: CRED:MY_VALIDATION_PEM'
#     Input Type: single
#     Required: true
#     Advanced: false
#   CHEF_CLIENT_VALIDATION_NAME:
#     Category: CHEF
#     Description: 'Validation name, along with the private SSH key, is used to determine
#       whether the Chef Client may register with the Chef Server. The validation_name
#       located on the Server and in the Client configuration file must match. Example:
#       ORG-validator'
#     Input Type: single
#     Required: true
#     Advanced: false
#   CHEF_CLIENT_SERVER_URL:
#     Category: CHEF
#     Description: 'Enter the URL to connect to the remote Chef Server. To connect to
#       the Opscode Hosted Chef use the following syntax https://api.opscode.com/organizations/ORGNAME.
#       Private Chef example: http://example.com:4000/chef'
#     Input Type: single
#     Required: true
#     Advanced: false
#   CHEF_CLIENT_LOG_LEVEL:
#     Category: CHEF
#     Description: 'The level of logging that will be stored in the log file. Example:
#       debug'
#     Input Type: single
#     Required: true
#     Advanced: true
#     Default: text:info
#     Possible Values:
#     - text:debug
#     - text:info
#     - text:warn
#     - text:error
#     - text:fatal
#   CHEF_CLIENT_NODE_NAME:
#     Category: CHEF
#     Description: 'Name which will be used to authenticate the Chef Client on the remote
#       Chef Server. If nothing is specified, the instance FQDN will be used. Example:
#       chef-client-host1'
#     Input Type: single
#     Required: false
#     Advanced: false
#   CHEF_CLIENT_LOG_LOCATION:
#     Category: CHEF
#     Description: 'The location of the log file. Example: C:/chef/chef-client.log'
#     Input Type: single
#     Required: true
#     Advanced: true
#     Default: text:C:/chef/chef-client.log
# Attachments: []
# ...
# Powershell RightScript to install chef client

# Stop and fail script when a command fails.
$errorActionPreference = "Stop"

######## INPUT validation ############
if (!$env:CHEF_CLIENT_NODE_NAME) {
  $env:CHEF_CLIENT_NODE_NAME=${env:computername}
  Write-Output("*** Input CHEF_CLIENT_NODE_NAME is undefined, using: $env:CHEF_CLIENT_NODE_NAME")
}
if ($env:CHEF_CLIENT_NODE_NAME -notmatch "^[\w -:\.]+$") {
  throw "*** ERROR: Input CHEF_CLIENT_NODE_NAME($env:CHEF_CLIENT_NODE_NAME) is invalid, aborting..."
}


if (!$env:CHEF_CLIENT_LOG_LOCATION) {
  $env:CHEF_CLIENT_LOG_LOCATION=join-path $chefDir "chef-client.log"
  Write-Output("*** Input CHEF_CLIENT_LOG_LOCATION is undefined, using: $env:CHEF_CLIENT_NODE_NAME")
}
if ($env:CHEF_CLIENT_LOG_LOCATION -notmatch "^[\w -\/:\.]+$") {
  throw "*** ERROR: Input CHEF_CLIENT_LOG_LOCATION($env:CHEF_CLIENT_LOG_LOCATION) is invalid, aborting..."
}


if (!$env:CHEF_CLIENT_LOG_LEVEL) {
  $env:CHEF_CLIENT_LOG_LEVEL="info"
  Write-Output("*** Input CHEF_CLIENT_LOG_LEVEL is undefined, using: $env:CHEF_CLIENT_LOG_LEVEL")
}
if ($env:CHEF_CLIENT_LOG_LEVEL -notmatch "^(debug|info|warn|error|fatal)$") {
  throw "*** ERROR: Input CHEF_CLIENT_LOG_LEVEL($env:CHEF_CLIENT_LOG_LEVEL) is invalid, aborting..."
}


if (!$env:CHEF_CLIENT_VALIDATION_NAME) {
  throw "*** ERROR: Input CHEF_CLIENT_VALIDATION_NAME is undefined, aborting..."
}
if ($env:CHEF_CLIENT_VALIDATION_NAME -notmatch "^[\w -:\.]+$") {
  throw "*** ERROR: Input CHEF_CLIENT_VALIDATION_NAME($env:CHEF_CLIENT_VALIDATION_NAME) is invalid, aborting..."
}

if (!$env:CHEF_CLIENT_SERVER_URL) {
  throw "*** ERROR: Input CHEF_CLIENT_SERVER_URL is undefined, aborting..."
}
if ($env:CHEF_CLIENT_SERVER_URL -notmatch "^[\w-:\.\/]+$") {
  throw "*** ERROR: Input CHEF_CLIENT_SERVER_URL($env:CHEF_CLIENT_SERVER_URL) is invalid, aborting..."
}

Write-Output("*** Creating $(join-path $chefDir 'validation.pem')")
echo $env:CHEF_CLIENT_VALIDATOR_PEM | Out-File -Encoding 'ASCII' $(join-path $chefDir 'validation.pem')

Write-Output("*** Creating $(join-path $chefDir 'client.rb')")
echo @"
# Managed by RightScale
# DO NOT EDIT BY HAND
#
log_level              :$env:CHEF_CLIENT_LOG_LEVEL
log_location           "$env:CHEF_CLIENT_LOG_LOCATION"
chef_server_url        "$env:CHEF_CLIENT_SERVER_URL"
validation_client_name "$env:CHEF_CLIENT_VALIDATION_NAME"
node_name              "$env:CHEF_CLIENT_NODE_NAME"
"@ | out-file -encoding 'ASCII' $(join-path $chefDir 'client.rb')

Start-Process -FilePath 'C:\opscode\chef\embedded\bin\ruby.exe' -ArgumentList 'C:\opscode\chef\bin\knife',' ssl fetch' -Wait