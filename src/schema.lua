-- SPDX-FileCopyrightText: 2020 Henri Chain <henri.chain@enioka.com>
--
-- SPDX-License-Identifier: Apache-2.0
-- modifications for Azure by Ali Kheyrollahi

local typedefs = require "kong.db.schema.typedefs"

return {
  name = "upstream-oauth2-3ready",
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            token_url = {
              type = "string",
              required = false
            }
          },
          {
            client_id = {
              type = "string",
              required = false
            }
          },
          {
            client_secret = {
              type = "string",
              required = false
            }
          },
          {
            scope = {
              type = "string",
              required = false
            }
          },
          {
            resource = {
              type = "string",
              required = false
            }
          },
          {
            managed_identity = {
              type = "boolean",
              required = false
            }
          }
        }
      }
    }
  }
}
