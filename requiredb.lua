local fullModulePattern = "^@([%w-]+):([%w%.-]+)$"
local modulePattern     = "^@([%w-]+)$"
local defaultDirectory  = ".requiredb"
local defaultRepository = "https://requiredb.alexdevs.me"

local expect            = require("cc.expect").expect
local sha256

-- REQUIREDB --

local function findVersion(version, versions)
    if version == "latest" then
        return versions[#versions]
    end
    for k, v in ipairs(versions) do
        if type(v) == "string" then
            return v
        elseif type(v) == "table" then
            if v.version == version then
                return v
            end
        end
    end
    return nil
end

local function init(options)
    expect(1, options, "table", "nil")

    options = options or {}
    local path = options.path or defaultDirectory
    local repository = options.repository or defaultRepository
    local useCache = options.useCache or true

    if not fs.exists(path) then
        fs.makeDir(fs.combine("", path))
    end

    local function from_libdb(fullName)
        local name, version = fullName:match(fullModulePattern)
        if not name then
            name, version = fullName:match(modulePattern), "latest"
        end

        if not name then
            return nil, "package name is not a libdb name"
        end

        local libpath = fs.combine(path, string.format("%s/%s", name, version))
        local content
        if fs.exists(libpath) and useCache then
            local f = fs.open(libpath, "r")
            content = f.readAll()
            f.close()
        else
            local h, err = http.get(("%s/packages/%s/index.json"):format(repository, name))
            if not h then
                return nil, err
            end

            local index = textutils.unserialiseJSON(h.readAll())
            h.close()

            local versionInfo = findVersion(version, index.versions)
            if not versionInfo then
                return nil, "version " .. version .. " not found"
            end

            if type(versionInfo) == "string" then
                local h, err = http.get(("%s/packages/%s/versions/%s.lua"):format(repository, name, versionInfo))
                if not h then
                    return nil, err
                end

                content = h.readAll()
                h.close()
            else
                if type(versionInfo.upstream) ~= "string" or type(versionInfo.hash) ~= "string" then
                    return nil, "invalid package version info"
                end

                local h, err = http.get(versionInfo.upstream)
                if not h then
                    return nil, err
                end

                sha256 = sha256 or require("@sha256")

                content = h.readAll()
                h.close()

                local upstreamDigest = sha256.digest(content):toHex()
                if versionInfo.hash:lower() ~= upstreamDigest then
                    return nil, "hash mismatch, expected " .. versionInfo.hash:lower() .. ", got " .. upstreamDigest
                end
            end

            if useCache then
                local f = fs.open(libpath, "w")
                f.write(content)
                f.close()
            end
        end

        local fn, err = load(content, name, nil, _ENV)
        if fn then
            return fn, name
        else
            return nil, err
        end
    end

    table.insert(package.loaders, from_libdb)

    local rdb = {}
    function rdb.getInfo(name)
        expect(1, name, "string")
        local h, err = http.get(("%s/packages/%s/index.json"):format(repository, name))
        if not h then
            return nil, err
        end

        local index = textutils.unserialiseJSON(h.readAll())
        h.close()

        if index.license == "custom" then
            local h, err = http.get(("%s/packages/%s/LICENSE"):format(repository, name))
            if h then
                index.license = h.readAll()
                h.close()
            end
        end

        return index
    end

    return rdb
end

return init
