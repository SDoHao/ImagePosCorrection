KeyEvent = {}
local KeyHash = {}
local KeyValue = {}

function KeyEvent.addEvent(key,func,value)
    KeyHash[key] = func
    KeyValue[key] = value
end

function KeyEvent.trigger(key)
    if(KeyHash[key])then
        KeyHash[key](KeyValue[key])
    end
end

return KeyEvent