SLASH_INITLE1 = "/initle"
SLASH_STOPLE1 = "/stople"

local VERBS = {"lf", "wtb"}
local frame  = CreateFrame("Frame");
local CurrentPlayerName = UnitName("player");
local invitedPlayer = nil
local isPortalSellingRunning = false

local VERB_CHILD = {
    "mage portal", "mage port", "portal to", "port to", "portal", "port",
    "mage water", "water mage", "mage food", "food mage"
}

local function cleanName(input)
    local result = string.find(input, "-")

    if result == nil then
        return ""
    else
        return string.sub(input, 0, result - 1)
    end
end

local function IsVerbAllowed(verb)
    for i, name in ipairs(VERBS) do if name == verb then return true end end
    return false
end


-- Inicia o Processo enviando pedido de grupo.
local function HandleInvite(playerName)
    local inInstance, instanceType = IsInInstance()

    if inInstance == true then
        print(">>> Jogador " .. playerName .. " esta em um grupo. enviando PM")
        -- Enviar PM pro jogador sair do grupo.
    else

        StartPortalSelling(playerName)

    end
end

local function StartPortalSelling(playerName)
    if isPortalSellingRunning == true then
        print("> Skippando portal pois vc já está vendendo um.")
    else
        -- Inicia a venda do portal.
        isPortalSellingRunning = true
        invitedPlayer = playerName
        InviteUnit(playerName)
    end
end

local function OnGroupJoined(self, event, ...)

    local name = ...
    if name == invitedPlayer then
        print(">> O jogador " .. invitedPlayer .. " aceitou o grupo. Tentando iniciar trade.")
        -- Start checking for the player to come within range
        checkAndInitiateTrade(invitedPlayer)
    end

end

local function checkAndInitiateTrade(characterName)
    -- Check if the other player is within range
    local interactDistance = CheckInteractDistance("player", characterName)
    if interactDistance and interactDistance <= 2 then
        -- Initiate the trade
        print(">> Enviando trade para " .. invitedPlayer)

        InitiateTrade(characterName)

        -- Wait for the trade window to open
        print (">> Esperando aceitar o pedido...")
        while not TradeFrame:IsShown() do
            -- Wait for the trade window to show
            Sleep(100)
        end

        print(">> Esperando por pelo menos 1 gold...")
        -- Espera por gold
        local gold = GetPlayerTradeMoney()
        while not gold >= 1 do
            Sleep(1000)
            gold = GetPlayerTradeMoney()
        end

        print(">> Boa, pelo menos 1 gold. Aceitando trade.")
        AcceptTrade()

        print (">> Ae, pode spawnar o portal pro maluco agora.")
    else

        print (">> Jogador " .. invitedPlayer .. " ainda não ta no range do trade. Esperando 1 segundo.")
        -- Schedule another check in 1 second
        C_Timer.After(1, function() checkAndInitiateTrade(characterName) end)
    end
end


-- Handle de quando aceita trade
local function OnTradeAcceptUpdate(self, event, ...)
    local name = UnitName("NPC")
    if name == invitedPlayer then
        AcceptTrade()
        print("Troca com o jogador " .. invitedPlayer .. " foi iniciada.")
    end
end


-- Funções que dão handle em mensagens do chat
local function myChatFilter(self, event, msg, author, language, channelName,
                            target, flags, zoneID, channelNumber, ...)

    local lowerMsg = string.lower(msg);

    local primeiroEspaco = string.find(lowerMsg, " ")
    local verbo = ""
  
    if (primeiroEspaco == nil) then
        verbo = lowerMsg
    else
        verbo = string.sub(lowerMsg, 0, primeiroEspaco - 1)
    end

    -- Check verb
    if IsVerbAllowed(verbo) then
        -- É WTB ou LF. Verificar na frase inteira quantas ocorrências das palavras tem.

        local ocorrencias = 0
        for i, name in ipairs(VERB_CHILD) do
            if string.find(lowerMsg, name) then
                ocorrencias = ocorrencias + 1
            end
        end

        -- print(">> Ocorrencias:" .. ocorrencias .. " > (" .. msg .. ")")

        -- Se achou pelo menos um, envia portal.
        if ocorrencias > 0 then
            print(">> PORTAL DETECTADO (" .. msg .. ")")

            HandleInvite(cleanName(author))
        end

    end
end

local function WhisperEventHandler(self, event, ...)
    local message, sender = ...
    if event == "CHAT_MSG_WHISPER" then
        -- Perform an action here, such as printing the sender's name and message
        -- print(sender .. " whispered: " .. message)
        
        if message == "pst" or message == "inv" then
            HandleInvite(sender)
            print(">> Pedido de grupo enviado para " .. sender)
        end
    end
end




local function InitLeHandler()

    -- Seta os hooks para ler mensagens.
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", myChatFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", myChatFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", myChatFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", WhisperEventHandler)

    -- Evento de grupo aceito
    frame:RegisterEvent("GROUP_JOINED")
    frame:SetScript("OnEvent", OnGroupJoined)

    -- Evento de trade aceito
    frame:RegisterEvent("TRADE_ACCEPT_UPDATE")
    frame:SetScript("OnEvent", OnTradeAcceptUpdate)

    -- frame:RegisterEvent("PARTY_INVITE_REQUEST")
    -- frame:SetScript("OnEvent", PartyInviteEventHandler)

     print("Addon Iniciado! - Detectando PM's e aceitando pedido de grupo")
end

local function StopLeHandler()
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", myChatFilter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SAY", myChatFilter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_YELL", myChatFilter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER", WhisperEventHandler)

    -- frame:UnregisterEvent("PARTY_INVITE_REQUEST")

    print("Addon Terminado! - Não detectando mais PM's e nem aceitando pedidos de grupo")
end


-- local function PartyInviteEventHandler(self, event, ...)
--     local inviter = ...
--     if event == "PARTY_INVITE_REQUEST" then
--         -- Accept the party invite
--         AcceptGroup()
--         print("Party invite from " .. inviter .. " accepted!")
--         PlaySoundFile("sound.wav")
--     end
-- end

SlashCmdList["INITLE"] = InitLeHandler;
SlashCmdList["STOPLE"] = StopLeHandler;
