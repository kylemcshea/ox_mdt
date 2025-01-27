---@type Calls
local activeCalls = {}

---@type Calls
local completedCalls = {}

local callId = 0
local utils = require 'server.utils'
local units = require 'server.units'
local officers = require 'server.officers'

---@param data CallData
function createCall(data)
    activeCalls[callId] = {
        code = data.code,
        offense = data.offense,
        completed = false,
        units = {},
        coords = data.coords,
        blip = data.blip,
        info = {
            time = os.time() * 1000,
            location = '',
            plate = data.info.plate,
            vehicle = data.info.vehicle
        }
    }

    officers.triggerEvent('ox_mdt:createCall', { id = callId, call = activeCalls[callId] })
    callId += 1

    return callId - 1
end

exports('createCall', createCall)

---@param callId number
---@param coords table
function updateCallCoords(callId, coords)
    if not activeCalls[callId] then return end

    activeCalls[callId].coords = coords

    officers.triggerEvent('ox_mdt:updateCallCoords', { id = callId, coords = coords })
end

exports('updateCallCoords', updateCallCoords)

Citizen.SetTimeout(7500, function()
    local coords = GetEntityCoords(GetPlayerPed(1))

    local id = createCall({
        offense = 'Speeding',
        code = '10-69',
        blip = 51,
        info = {
            plate = 'XYZ 123',
            vehicle = 'Dinka Blista'
        },
        coords = {coords.x, coords.y}
    })

    -- local multiplier = 1
    -- SetInterval(function()
    --     updateCallCoords(id, {coords.x * multiplier, coords.y * multiplier})
    --     multiplier += 1
    -- end, 1500)
end)

---@param source number
---@param data 'active' | 'completed'
utils.registerCallback('ox_mdt:getCalls', function(source, data)
    return data == 'active' and activeCalls or completedCalls
end)

---@param source number
---@param id number
utils.registerCallback('ox_mdt:attachToCall', function(source, id)
    local playerUnitId = Player(source).state.mdtUnitId --[[@as number]]

    if not playerUnitId or activeCalls[id].units[playerUnitId] then return false end

    activeCalls[id].units[playerUnitId] = units.getUnit(playerUnitId)

    -- Used to update a call notification - does not refresh calls list in the MDT
    officers.triggerEvent('ox_mdt:editCallUnits', { id = id, units = activeCalls[id].units })

    return true
end)

---@param source number
---@param id number
utils.registerCallback('ox_mdt:detachFromCall', function(source, id)
    local playerUnitId = Player(source).state.mdtUnitId --[[@as number]]
    if not playerUnitId then return false end

    if not activeCalls[id].units[playerUnitId] then return false end

    activeCalls[id].units[playerUnitId] = nil

    -- Used to update a call notification - does not refresh calls list in the MDT
    officers.triggerEvent('ox_mdt:editCallUnits', { id = id, units = activeCalls[id].units })

    return true
end)

---@param source number
---@param id number
utils.registerCallback('ox_mdt:completeCall', function(source, id)
    if not activeCalls[id] then return end

    activeCalls[id].completed = os.time()
    completedCalls[id] = activeCalls[id]
    activeCalls[id] = nil

    return true
end)

---@param source number
---@param data {id: number, units: string[]}
utils.registerCallback('ox_mdt:setCallUnits', function(source, data)
    local officer = officers.get(source)

    --if not officer.isDispatch then return end

    activeCalls[data.id].units = {}
    for i = 1, #data.units do
        local unitId = data.units[i]
        activeCalls[data.id].units[unitId] = units.getUnit(unitId)
    end

    officers.triggerEvent('ox_mdt:setCallUnits', { id = data.id, units = activeCalls[data.id].units })

    return true
end)

-- Remove completed calls older than 1 hour every hour
lib.cron.new('0 */1 * * *', function()
    for id, call in pairs(completedCalls) do
        if os.time() - call.completed > 3600 then
            completedCalls[id] = nil
        end
    end
end)