-- SPDX-FileCopyrightText: 2020 Henri Chain <henri.chain@enioka.com>
-- Modified by aliostad to make v3 ready
-- SPDX-License-Identifier: Apache-2.0

local UpstreamOAuth2 = {
  PRIORITY = 802,
  VERSION = "1.0.0"
}

local tokens = require "kong.plugins.upstream-oauth2-3ready.tokens"
local socket = require "socket"

function UpstreamOAuth2:access(conf)

  local curtime = socket.gettime()
  local cache_key = tokens.get_cache_key(conf.token_url, 
    conf.client_id, conf.scope, conf.resource)
  local err, res

  for i = 1, 2 do
    res, err =
      kong.cache:get(
      cache_key,
      nil,
      tokens.get_access_token,
      conf.token_url,
      conf.client_id,
      conf.client_secret,
      "client_credentials",
      conf.scope,
      conf.resource
    )

    -- preventively ask for new access token if about to expire
    if res and res.expires_at and res.expires_at < curtime + 5 then
      kong.cache:invalidate_local(cache_key)
      kong.response.set_header("X-Token-Expired", curtime - res.expires_at)
    elseif res and res.access_token then
      break
    else
      kong.cache:invalidate_local(cache_key)
      return kong.response.exit(400, res or err)
    end
  end

  kong.service.request.set_header("Authorization", "Bearer " .. res.access_token)
  if (res.expires_at) then
    kong.response.set_header("X-Token-Expires-In", res.expires_at - curtime)
  end
end

function UpstreamOAuth2:header_filter(conf)
  local status = kong.response.get_status()
  -- If auth doesn't work, delete token from cache
  if status == 401 then
    kong.cache:invalidate(tokens.get_cache_key(conf.token_url, 
      conf.client_id, conf.scope, conf.resource))
  end
end

return UpstreamOAuth2
