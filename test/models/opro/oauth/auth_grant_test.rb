require 'test_helper'

class OproAuthGrantTest < ActiveSupport::TestCase
  test "duplicate access_tokens can't happen" do
    grant     = create_auth_grant
    dup_grant = create_auth_grant
    dup_grant.access_token = grant.access_token
    refute dup_grant.valid?
    assert dup_grant.errors.present?
  end

  test "unique_secure_token_for" do
    grant     = create_auth_grant
    token     = grant.access_token
    new_token = grant.unique_token_for(:access_token, token)
    assert_not_equal token, new_token
  end

  test "no expiration without access_token expiration time" do
    ::Opro.require_refresh_within = nil
    grant = create_auth_grant
    ::Opro.require_refresh_within = 1.day
    refute grant.expired?
  end
end
