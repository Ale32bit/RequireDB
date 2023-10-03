--[[
  WebPackage by AlexDevs
  
  Load packages from the web without downloading to files.
  (Requires HTTP to be enabled ofc)
  
  Usage:

  require("webpackage")
  local myPackage = require("https://pastebin.com/raw/pe3mgfdi")
]]

local function from_http(name)
    if not http.checkURL(name) then
        return nil, "package path is not an URL"
    end

    local h, hErr = http.get(name)
    if not h then
        return nil, hErr
    end

    local content = h.readAll()
    h.close()

    local fn, err = load(content, name, nil, _ENV)
    if fn then
        return fn, name
    else
        return nil, err
    end
end

table.insert(package.loaders, from_http)

return true