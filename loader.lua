-- JawaJutsuHub loader v1.0.0 (Baddies Jump)
-- This loader pins the release SHA-256. No network calls are made per jump.
local URL = "https://raw.githubusercontent.com/JawaJutsu/JawaJutsuHub/main/games/baddies-jump/v1.0.0.lua"
local EXPECTED_SHA256 = "4b65debc3260d73b4ac3ddf261fb0c2f29a14c733b9141d8dd601d772fb21e1a"

local ok, source = pcall(function() return game:HttpGet(URL) end)
if not ok or type(source) ~= "string" or #source == 0 then
    warn("[JawaJutsu] Download failed: " .. tostring(source))
    return
end

-- crypt.hash is not standardized across executors. An unsupported API
-- is explicitly reported; a mismatching supported hash blocks execution.
local hashFn = crypt and crypt.hash
if type(hashFn) == "function" then
    local hashed, digest = pcall(hashFn, source, "sha256")
    if not hashed or type(digest) ~= "string" or #digest ~= 64 then
        hashed, digest = pcall(hashFn, source)
    end
    if hashed and type(digest) == "string" and #digest == 64 then
        if digest:lower() ~= EXPECTED_SHA256 then
            warn("[JawaJutsu] SHA-256 mismatch: refusing to run")
            return
        end
        print("[JawaJutsu] SHA-256 verified")
    else
        warn("[JawaJutsu] SHA-256 UNVERIFIED: executor hash API incompatible")
    end
else
    warn("[JawaJutsu] SHA-256 UNVERIFIED: executor hash API unavailable")
end

if type(loadstring) ~= "function" then
    warn("[JawaJutsu] loadstring unavailable")
    return
end
local compiled, compileError = loadstring(source)
if not compiled then
    warn("[JawaJutsu] Compile error: " .. tostring(compileError))
    return
end
local success, runtimeError = pcall(compiled)
if not success then warn("[JawaJutsu] Runtime error: " .. tostring(runtimeError)) end
