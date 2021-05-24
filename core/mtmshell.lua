os.loadAPI("mtmos/core/utils")
os.loadAPI("mtmos/core/commands")

local args = {...} -- cli arguments, if any

-- BEGIN STATES: DECLARATION AND INITIALIZATION

-- these states are used by MTMOS to determine how an event should be responded
-- to, if at all. For example, if the "function_running" state is "true", then
-- only the currently running program should respond to new events, since that
-- program will likely respond to the events differently.

_G.global_states = {}
global_states["function_count"] = 0

-- END STATES

-- The interrupts here are (obviously) not actual processor interrupts. However,
-- they interrupt the currently running process(es) to fetch data for the current
-- function. Because the system uses events and the core of MTMOS listens for said
-- events, including various things done during a response to an event, this could
-- cause an endless loop if not handled. As such, I've opted to yield from the
-- function, fetch the data, and feed it back into the function when ready to
-- resume it.

interrupts = {} -- interrupt vector
_G.interrupts = interrupts


-- sends a get request over the internet
interrupts["http.get"] = function(data)
    return http.get(data).readAll()
end

-- host a desired protocol under the desired hostname
interrupts["rnhost"] = function(data)
    data = stringutils.split(data)
    rednet.host(data[1], data[2])
end

-- unhost a desired protocol under the desired hostname
interrupts["rnunhost"] = function(data)
    data = stringutils.split(data)
    rednet.unhost(data[1], data[2])
end

-- open a network channel on the specified face
interrupts["rnopen"] = function(data)
    rednet.open(data)
end



-- Because ComputerCraft revolves and functions around coroutines, it's important
-- to be able to handle them as they come in, and dispatch those events to the
-- corresponding event listeners. To accomplish this, upon an event the type of
-- event is checked, then looks through the registered event listeners to find
-- a listener waiting for that type and forwards the event to that listener.

-- for a list of native event types, see: http://www.computercraft.info/wiki/Os.pullEvent

CoroutineManager = {}
_G.CoroutineManager = CoroutineManager

CoroutineManager.listeners = {}



-- add an event listener to the bus;
-- Usage:
--      CoroutineManager.addListener(<thread>, <event_type>)

-- Example:
--      function my_print(stuff)
--          print(stuff)
--      end
--      my_thread = coroutine.create
--      CoroutineManager.addListener(my_thread, "key")

CoroutineManager.addListener = function(thread, event)
    if type(thread) ~= "thread" then
        error("func must be a coroutine. Please use coroutine.create(func)")
    end
    CoroutineManager.listeners[thread] = event
end


-- The main loop of MTMOS. Runs until the "exit" interrupt is used, which
-- returns to device to CraftOS.
CoroutineManager.main = function(...)
    while true do -- event dispatcher main loop
        local event_type, p1, p2, p3, p4, p5 = os.pullEvent()                                                   -- get event
        for k, v in pairs(CoroutineManager.listeners) do                                                        -- go through each listener
            if v == event_type then                                                                             -- if the listener's desired type is that of the current event
                local status, results = coroutine.resume(k, p1, p2, p3, p4, p5)                                 -- call the listener with the event arguments
                while results ~= nil do                                                                         -- loop until the listener has yielded a result of nil
                    results = stringutils.split(results)                                                        -- split the result into separate words
                    local interrupt = results[1]                                                                -- get the first word from results
                    table.remove(results, 1)                                                                    -- remove the first word from results
                    if k == shell_key_coroutine and interrupt == "exit" then                                    -- exit condition
                        return                                                                                  -- exit
                    else
                        status, results = coroutine.resume(k, interrupts[interrupt](stringutils.join(results))) -- resume the coroutine while providing requested data
                    end
                end
            end
        end
    end
end

os.loadAPI("mtmos/core/coroutines")

if args[1] == 'run' then
    shell.run("clear")
    printf("&2MTMOS V0.1.0")

    coroutine.resume(shell_char_routine, '')

    CoroutineManager.main()
end