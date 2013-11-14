-- A little conjur library for nginx + lua

-- You don't mind if we polute your global namespace a bit, do you?
conjur = {}


-- Some global options for conjur
conjur.options = {
  account = 'sandbox',
  stack   = 'v4'
}


-- Initialize host credentials by reading them from netrc.
-- Uses conjur.options.account to determine the host to use.
-- If credentials are already loaded into shared memory, does
-- not reload them.
function conjur.init_host_credentials()
  local user,pass = conjur.get_host_credentials()
  if user then return user,pass end
  local host = 'https://authn-' .. conjur.options.account .. '-conjur.herokuapp.com'
  local netrc = require('netrc')
  local machine = netrc[host]
  if not machine then error('no credentials for ' .. host) end
  user, pass = machine.login, machine.password
  conjur.set_host_credentials(user, pass)
  return user, pass
end

-- Set host credentials in shared memory
function conjur.set_host_credentials(login, password)
  local shared = conjur.get_shared_dict()
  shared:set('conjur_host_login', login)
  shared:set('conjur_host_password', password)
  return login, password
end


-- Fetch credentials from shared memory
function conjur.get_host_credentials()
  local shared = conjur.get_shared_dict()
  return shared:get('conjur_host_login'), shared:get('conjur_host_password')
end

-- Get the shared dictionary we use, error if it isn't 
-- found.
function conjur.get_shared_dict()
  return ngx.shared.conjur or error('You are missing a lua_shared_dict conjur directive in your nginx config')
end

-- Authenticate as the conjur identitiy given by the 
-- credentials set by conjur.set_host_credentials.  Uses
-- a cached token if one is available, otherwise fetches
-- one from authn.  
-- *NOTE* to use this function you must include 'conjur-authn.conf'
-- in the server config.
function conjur.authenticate_host()
  local shared = conjur.get_shared_dict()
  local token  = shared:get('conjur_host_token')
  
  -- Not cached yet, or it expired, we'll have to get a new one.
  if not token then 
    local login, password = conjur.get_host_credentials()
    if not login then error('You have not set conjur host credentials') end
    
    -- fetch token from the conjur authn service
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
    token = 'Token token="' .. ngx.encode_base64(response.body) .. '"'

    -- set with an exptime of 7 minutes, just short of the lifespan of a token
    shared:set('conjur_host_token', token, 7 * 60)
  end

  ngx.req.set_header('Authorization', token)
end




