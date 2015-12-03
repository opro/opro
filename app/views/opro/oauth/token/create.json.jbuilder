json.access_token @auth_grant.access_token
json.token_type Opro.token_type || 'bearer'
json.refresh_token @auth_grant.refresh_token
json.expires_in @auth_grant.expires_in