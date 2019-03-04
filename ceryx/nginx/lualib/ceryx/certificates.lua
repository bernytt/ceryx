local redis = require "ceryx.redis"
local ssl = require "ngx.ssl"

local exports = {}

function getRedisKeyForHost(host)
    return redis.prefix .. ":certificates:" .. host
end

function getCertificatesForHost(host)
    ngx.log(ngx.DEBUG, "Looking for SSL sertificate for " .. host)

    local certificates_redis_key = getRedisKeyForHost(host)
    local certificate_path, certificate_err = redisClient:hget(certificates_redis_key, "certificate_path")
    local key_path, key_err = redisClient:hget(certificates_redis_key, "key_path")

    if certificate == nil then
        ngx.log(
            ngx.ERROR,
            "Could not retrieve SSL certificate path for " .. host .. " from Redis: " .. (certificate_err or "N/A")
        )
        return nil
    end

    if key_path == nil then
        ngx.log(ngx.ERROR, "Could not retrieve SSL key path for " .. host .. " from Redis: " .. (key_err or "N/A"))
        return nil
    end

    ngx.log(ngx.DEBUG, "Found SSL certificates for " .. host .. " in Redis.")

    local certificate_data = utils.read_file(certificate_path)
    local key_data = utils.read_file(key_path)
    local data = {}

    data["certificate"] = certificate_data
    data["key"] = key_data

    return data
end

exports.getCertificatesForHost = getCertificatesForHost

return exports
