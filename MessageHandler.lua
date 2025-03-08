MessageHandler = {}

function MessageHandler:RegistrarEventos()

    print("> Registrando eventos...")

    -- ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", MessageHandler:OnChatMessage)
    -- ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", MessageHandler:OnChatMessage)
    -- ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", MessageHandler:OnChatMessage)
    -- ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", MessageHandler:WhisperEventHandler)

end

function MessageHandler:OnChatMessage(self, event, msg, author, language, channelName,
    target, flags, zoneID, channelNumber, ...)

    print("chat recebido")

end

function MessageHandler:WhisperEventHandler(self, event, ...)

end

function MessageHandler:RemoverEventos()
    print("> Removendo eventos...")

    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", MessageHandler:OnChatMessage)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SAY", MessageHandler:OnChatMessage)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_YELL", MessageHandler:OnChatMessage)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER", MessageHandler:WhisperEventHandler)

end