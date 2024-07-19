# kong-plugin-upstream-oauth2
A Kong plugin to negotiate oauth2 authentication with upstream services

Currently only supports the client credentials grant

# NOTE

This is a fork of https://github.com/enioka-Haute-Couture/kong-plugin-upstream-oauth2 which has stopped working after [removing BaseHandler](https://docs.konghq.com/gateway/latest/plugin-development/custom-logic/#migrating-from-baseplugin-module) in version 3+ of Kong.

The package is available as `kong-plugin-upstream-oauth2-3ready`:

``` shell
luarocks install kong-plugin-upstream-oauth2-3ready
```

## Changes

1. Removing BaseHandler
1. Adding `resource` as a new optional parameter alongside `scope` which is sometimes used in Azure AD (Entra ID) [token creation](kong-plugin-upstream-oauth2-3ready).
2. Adding `managed_identity` (boolean flag) for retrieving access token of the Managed Identity of Azure resources such as VM, AKS, etc. When `managed_identity` is true, all parameters are ignored; if `url` is supplied it will be used but by default it will be default URL for the System Assigned Managed Identity which is `http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F` which is a non-routable URL only accessible to the processes/containers running locally - see [here](https://github.com/arsenvlad/azure-managed-app-aks-managed-identity
) for reference.