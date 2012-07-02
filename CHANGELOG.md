## 0.3.0

- Properly set attr_accessible for those apps that are requiring all attributes to be whitelisted.
- Allow access_token to be passed in header `curl -H "Authorization: token iAmAOaUthToken" http://localhost:3000`
- Default `config.password_exchange_enabled' to true
- Allow multiple `find_user_for_auth` calls in setup to allow custom finders for facebook, etc.
- You can now Rate limit incoming client applications.

## 0.2.0

- Allow password exchange for access_token using `config.password_exchange_enabled = true`

## 0.1.0

- Refresh Token Support
- Scoped permissions support
- Docs, Test, and ClientApp controllers can be skipped or over-ridden

## 0.0.1

- Initial Release