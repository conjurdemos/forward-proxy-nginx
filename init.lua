-- This script runs once in each worker when it starts up.  The first
-- run will read the credentials from a file, and save them to shared
-- memory accessible to all workers.

-- The path we want to read from.  It's hardcoded here but you could also put it 
-- in an environment variable.

local shared = ngx.shared.conjur or error("you need a lua_shared_dict conjur directive")

-- Check to see if we are the first worker (actually the nginx init processes, but same difference)
if not shared:get("conjur_host_login") then
  local netrc = require('netrc')
  -- Use a hardcoded host here.  In real life you might for example get one 
  -- from the environment.
  local machine = netrc['https://authn-sandbox-conjur.herokuapp.com']
  -- Cache the credentials in shared memory.  This is a trifle unsafe but 
  -- beats loading the netrc file every time.
  shared:set('conjur_host_login', machine.login)
  shared:set('conjur_host_password', machine.password)
end