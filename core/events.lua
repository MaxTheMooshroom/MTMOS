require("modules/structs")
require("modules/uuid")
require("programs")


_G.Events = {}
Events.global_listeners = {}
Events.event_queue = Queue()

function Events.addListenerType(type)
    Events.global_listeners[type] = {}
end

function Events.addListener(type, listener)
    if Events.global_listeners[type] == nil then Events.addListenerType(type) end
    table.insert(Events.global_listeners[type], listener)
end

local hiatus_timer_id

function Events.new(_type, p1, p2, p3, p4, p5)
    local new_event = {}

    new_event.thread = coroutine.running()
    new_event.uuid = UUID()
    new_event.type = _type
    new_event.p1 = p1
    new_event.p2 = p2
    new_event.p3 = p3
    new_event.p4 = p4
    new_event.p5 = p5

    -- target should be 'global', nil, or string name of target program.
    -- target nil:              dispatch to the program that made the event
    -- target "global":         dispatch to global listeners and every program
    -- target <program name>:   dispatch to program with matching name.
    new_event.target = nil

    -- dispatch event to its destination
    function new_event.dispatch(self)
        if self.target == 'global' then
            if Events.global_listeners[self.type] == nil then Events.addListenerType(self.type) end
            for i=1, #Events.global_listeners[self.type] do
                Events.global_listeners[self.type][i](self)
            end
            for _, v in pairs(PROGRAM_LIST) do
                v.eq:push(self)
            end
        else
            local prog
            if self.target == nil then
                prog = Programs.findByThread(self.thread)
            elseif type(self.target) == 'string' then
                prog = Programs.findByName(self.target)
            end
            if prog ~= nil then
                prog.eq:push(self)
            elseif type(target) == 'string' then
                printf('&eProgram "'..self.target..'" was not found')
            elseif type(self.target) == 'thread' then
                printf('&eProgram was not found using provided thread')
            end
        end
    end

    return new_event
end

local start = 0
local last_epoch = os.epoch()

function Events.dispatch(limit)
    local eq_size = Events.event_queue:size()
    while eq_size > 0 do
        local _event = Events.new(unpack(Events.event_queue:pop()))
        _event.target = 'global'
        _event:dispatch(true)
        eq_size = Events.event_queue:size()
    end
end

function Events.poll()
    hiatus_timer_id = os.startTimer(0.05)
    while true do
        local args = {coroutine.yield()}
        local should_push = true
        if args[1] == "timer" and args[2] == hiatus_timer_id then
            hiatus_timer_id = os.startTimer(0.05)
            should_push = false
        elseif args[1] == "http_success" then
            io.write('.')
            if args[3] ~= nil then
                io.write(',')
                local response = args[3]
                local headers = response.getResponseHeaders()
                if headers['Uuid'] ~= nil then
                    io.write(';')
                    local prog_uuid = UUID(headers['Uuid'])
                    local prog_to_resume = Programs.findByUuid(prog_uuid)
                    prog_to_resume.suspended = false
                    print('========='..prog_to_resume.name)
                    local http_event = Events.new(args[1], args[2], args[3])
                    http_event.target = prog_to_resume
                    http_event:dispatch()
                end
            end
        else
            os.cancelTimer(hiatus_timer_id)
            hiatus_timer_id = os.startTimer(0.05)
        end
        if should_push == true then Events.event_queue:push(args) end
    end
end
