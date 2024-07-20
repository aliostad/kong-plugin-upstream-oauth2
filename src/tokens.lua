-- SPDX-FileCopyrightText: 2020 Henri Chain <henri.chain@enioka.com>
--
-- SPDX-License-Identifier: Apache-2.0
-- modifications for Azure by Ali Kheyrollahi

local http = require "socket.http"
local https = require "ssl.https"
local cjson_safe = require "cjson.safe"
local urlmodule = require "socket.url"
local ltn12 = require "ltn12"
local socket = require "socket"

function get_cache_key(token_url, client_id, scope, resource, managed_identity)
    return "upstream_oauth2_token_" .. (token_url or "") .. "_" .. (client_id or "") .. "_" .. (scope or "") .. (resource or "") .. tostring(managed_identity or "")
end

function get_access_token(url, client_id, client_secret, grant_type, scope, resource, managed_identity)
    local final_url = url
    if (not url) and managed_identity then
        final_url = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F"
    end

    local parsed = urlmodule.parse(final_url)
    local request
    local method = managed_identity and "GET" or "POST"

    if parsed.scheme == "https" then
        request = https.request
    else
        request = http.request
    end

    local req_body =
        ngx.encode_args(
        {
            grant_type = grant_type,
            client_id = client_id,
            client_secret = client_secret,
            scope = scope,
            resource = resource
        }
    )

    local headers = managed_identity and {
        ["Metadata"] = "true"
    } or {
        ["Content-Length"] = tostring(#req_body),
        ["Content-Type"] = "application/x-www-form-urlencoded"
    }

    local res_body = {}
    local source = nil
    if not managed_identity then
        source = ltn12.source.string(req_body)
    end

    local ok, status =
        request(
        {
            method = method,
            source = source,
            headers = headers,
            url = final_url,
            port = parsed.port,
            sink = ltn12.sink.table(res_body)
        }
    )

    local res_body = table.concat(res_body)
    local res_json, err = cjson_safe.decode(res_body)

    if not res_json then
        return {
            status = status,
            error = "Can't get tokens: bad json response",
            response = res_body
        }
    end
    if status == 200 then
        return {
            access_token = res_json.access_token,
            expires_at = res_json.expires_in and tonumber(res_json.expires_in) + socket.gettime()
        }
    end
    return {status = status, error = "Can't get tokens: bad response code", response = res_json}
end

return {
    get_access_token = get_access_token,
    get_cache_key = get_cache_key
}
