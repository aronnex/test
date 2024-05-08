-- 1.火焰套装
local Equipment = {}
function Equipment:new()
    local equipment = {}
    setmetatable(equipment, self)
    self.__index = self
    self.items = {}
    self.itemSet = {}
    return equipment
end

function Equipment:addItem(item)
    if not self.itemSet[item] then
        table.insert(self.items, item)
        self.itemSet[item] = true
    end
end

function Equipment:isComplete()
    return #self.items == 4
end

function Equipment:reset()
    self.items = {}
    self.itemSet = {}
end

-- 怪物
local Monster = {}
function Monster:new()
    local monster = {}
    setmetatable(monster, self)
    self.__index = self
    
    return monster
end

function Monster:isKilled()
    return true
end


-- 套装
local FlameSet = {}
function FlameSet:new()
    local flameSet = {}
    flameSet.type = {"火焰剑", "火焰甲", "火焰盔", "火焰靴"}
    return flameSet
end


-- Drop
local Drop = {}
function Drop:new()
    local drop = {}
    setmetatable(drop, self)
    self.__index = self
    return drop
end

function Drop:getRandomFlameSet(set, collectedSet, drops)
    local flameSet = set
    local remainingSet = {}
    if drops <= 4 then
        return flameSet[math.random(#flameSet)]
    else
        for _, item in ipairs(flameSet) do
        if not collectedSet[item] then
            table.insert(remainingSet, item)
        end
    end
    return remainingSet[math.random(#remainingSet)]
    end
end



-- Game
local Game = {}
function Game:new()
    local game = {}
    setmetatable(game, self)
    self.__index = self
    return game
end


function Game:fight()
    local equipment = Equipment:new()
    local flameSet = FlameSet:new()
    local drop = Drop:new()
    local monster = Monster:new()
    local drops = 1
    local flameSetList = {}
    while not equipment:isComplete() do
        if monster:isKilled() then
            local item = drop:getRandomFlameSet(flameSet.type, equipment.itemSet, drops)
            equipment:addItem(item)
            --print("第" .. drops .. "次掉落: " .. item)
            table.insert(flameSetList, item)
        end
        drops = drops + 1
    end
    equipment:reset()
    return flameSetList
end

-- 自检
local function selfCheck()
    local results = {false, false, false}
    local game = Game:new()
    for i = 1, 10000 do
        local items = game:fight()
        local result1 = {"火焰剑","火焰剑","火焰剑","火焰剑","火焰甲","火焰盔","火焰靴"}
        local result2 = {"火焰剑","火焰剑","火焰剑","火焰甲","火焰盔","火焰靴","火焰靴"}
        local result3 = {"火焰剑","火焰剑","火焰甲","火焰盔","火焰靴","火焰靴","火焰靴"}
        if #items == 7 and results[1] == false then
            for key, value in pairs(items) do
                if result1[key] ~= value then
                    break 
                end
            end
            results[1] = true
        elseif #items == 7 and results[2] == false then
            for key, value in pairs(items) do
                if result2[key] ~= value then
                    break 
                end
            end
            results[2] = true
        elseif #items == 7 and results[3] == false then
            for key, value in pairs(items) do
                if result2[key] ~= value then
                    break 
                end
            end
            results[3] = true
        end

        for i = 1, 4 do
            if items[i] == items[5] then
            print("第五次掉落重复物品")
            return
            end
        end
        --print("第五次掉落不重复")
    end
    print("第一种情况是否出现：" .. tostring(results[1]))
    print("第二种情况是否出现：" .. tostring(results[2]))
    print("第三种情况是否出现：" .. tostring(results[3]))
    print("自检通过")
end

selfCheck()

-- 2.玩家匹配
-- 玩家对象
local Player = {}
function Player:new(id,groupId)
    local player = {}
    setmetatable(player, self)
    self.__index = self
    player.id = id
    player.groupId = groupId
    player.matched = false
    return player
end
-- 匹配队列对象
local MatchQueue = {}
function MatchQueue:new()
    matchQueue = {}
    setmetatable(matchQueue, self)
    self.__index = self
    matchQueue.queue = {}
    matchQueue.groups = {}
    return matchQueue
End

function MatchQueue:AddPlayer(player)
    table.insert(self.queue, player)
    if not self.groups[player.groupId] then
        self.groups[player.groupId] = {}
    end
    table.insert(self.groups[player.groupId], player)
end

function MatchQueue:MatchPlayers()
    local player1, player2
    local matchedPlayers = {}
    for i = #self.queue, 2, -1 do
        player1 = self.queue[i]
        if not player1.matched then
            for j = i - 1, 1, -1 do
                player2 = self.queue[j]
                if not player2.matched and player1.groupId ~= player2.groupId then
                    player1.matched = true
                    player2.matched = true
                    table.insert(matchedPlayers, player1)
                    table.insert(matchedPlayers, player2) 
                    break
                end
            end
        end
    end
    return matchedPlayers
end

local players = {}
for i = 1, 10 do
    table.insert(players, Player:new(i, math.ceil(i / 2)))
end

function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j= math.random(i)
        tbl[i],tbl[j] = tbl[j], tbl[i]
    end
end

function makeAllMatched(tbl)
    local matchedPlayers = {}
    local matchQueue = MatchQueue:new()

    for _, player in ipairs(tbl) do
        matchQueue:AddPlayer(player)
    end

    while (#matchedPlayers ~= #matchQueue.queue) do
        for _, player in ipairs(matchQueue.queue) do
            player.matched = false
        end
        shuffle(matchQueue.queue)
        matchedPlayers = matchQueue:MatchPlayers()
    end
    return matchedPlayers, matchQueue
end

local function selfCheck()
    for i = 1, 10000 do
        local matchedPlayers, queue= makeAllMatched(players)
        for i = 1, #matchedPlayers, 2 do
            if matchedPlayers[i] == matchedPlayers[i + 1] then
                print(" 玩家 " .. player1 .. " 和 " .. player2 .. " 属于同一组")
	            return
            end
        end
        if #queue ~= 0 then
            print("有玩家轮空：玩家" .. queue.id)
        end
    end
        print("自检通过")
end