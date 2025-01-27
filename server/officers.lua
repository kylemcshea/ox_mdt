---@type table<number, Officer>
local activeOfficers = {}
local officersArray = {}

---Triggers a client event for all active officers.
---@param eventName string
---@param eventData any
local function triggerOfficerEvent(eventName, eventData)
    for playerId in pairs(activeOfficers) do
        TriggerClientEvent(eventName, playerId, eventData)
    end
end

SetInterval(function()
    local n = 0

    for _, officer in pairs(activeOfficers) do
        local coords = GetEntityCoords(officer.ped)
        officer.position[1] = coords.y
        officer.position[2] = coords.x
        officer.position[3] = coords.z
        n += 1
        officersArray[n] = officer
    end

    triggerOfficerEvent('ox_mdt:updateOfficerPositions', officersArray)
    table.wipe(officersArray)
end, math.max(500, GetConvarInt('mdt:positionRefreshInterval', 5000)))

local function addOfficer(playerId, firstName, lastName, stateId, callSign)
    activeOfficers[playerId] = {
        firstName = firstName,
        lastName = lastName,
        stateId = stateId,
        callSign = math.random(100, 999),
        playerId = playerId,
        ped = GetPlayerPed(playerId),
        position = {},
    }
end

local function removeOfficer(playerId)
    activeOfficers[playerId] = nil
end

local function getOfficer(playerId)
    return activeOfficers[playerId]
end

local function getAll() return activeOfficers end

return {
    add = addOfficer,
    remove = removeOfficer,
    get = getOfficer,
    getAll = getAll,
    triggerEvent = triggerOfficerEvent
}
