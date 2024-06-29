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