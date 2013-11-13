-- we store a cached token in shared memory.
local shared = ngx.shared.conjur or error("You're missing a lua_shared_dict conjur directive")
local cached = shared:get("conjur_host_token")

if cached then
  -- got it, good.  Set the request header and we're done.
  ngx.req.set_header("Authorization", cached)
  -- no need to do this in real life, but it's nice to know when it worked
  ngx.log(ngx.ERR, 'Using cached authn token')
  return
end

-- fetch the password:login pair from shared memory
local login = shared:get('conjur_host_login')
local password = shared:get('conjur_host_password')

-- now we need to request the token from the conjur authn service
local response = ngx.location.capture('/conjur/authn', {
    method = ngx.HTTP_POST,
    body   = password,
    ctx    = { login = login }
})

if response.status >= 300 then
  -- just error out, will cause the request to fail with 500, which seems appropriate
  error("authn request failed with " .. response.status)
end

-- base64 the body and turn it into a header we can use
local token = ngx.encode_base64(response.body)
token = 'Token token="' .. token .. '"'

-- set with an exptime of 7 minutes, just short of the lifespan of a token
shared:set('conjur_host_token', token, 7 * 60)

ngx.req.set_header('Authorization', token)

-- no need to do this in real life, but it's nice to know when it worked
ngx.log(ngx.ERR, 'Using fresh authn token')

