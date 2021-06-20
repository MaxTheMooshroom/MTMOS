require("modules/uuid")


_G.Programs = {}
_G.PROGRAM_LIST = {}
_G.FOCUSED_PROGRAM = nil

function Programs.renderFocused()
    while true do
        if FOCUSED_PROGRAM ~= nil then
            FOCUSED_PROGRAM.drawFunc()
        end
        coroutine.yield()
    end
end

function Programs.setFocusedProgram(program)
    if program == nil then return end
    if FOCUSED_PROGRAM ~= nil then FOCUSED_PROGRAM.window.setVisible(false) end
    FOCUSED_PROGRAM = program
    FOCUSED_PROGRAM.window.setVisible(true)
    term.redirect(FOCUSED_PROGRAM.window)
end

function Programs.make(module, arguments)

    if module.Main == nil or module.Info == nil then
        printf('&eProgram is either missing the Main or Info function.')
        return
    end

    local new_program = {}
    new_program.module = module
    module.container = new_program
    new_program.suspended = false                                               -- Program.tick will skip execution of the programs with 'suspended' set to true
    new_program.uuid = UUID()
    new_program.eq = Queue()

    -- programs that draw to the screen can specify a monitor to output to in Info(). If nil, draws to native.
    new_program.monitor = nil

    setfenv(new_program.module.Info, getfenv())
    new_program.module.Info()                                                   -- programs must have an "Info" function that receives the program object
    if new_program.name == nil then error("Program was not named") end          -- Info() must set name of program

    setfenv(new_program.module.Main, getfenv())
    new_program.main_thread = coroutine.create(new_program.module.Main)         -- programs must have a "Main" function that receives the program object
    if new_program.module.Draw ~= nil then                                      -- programs that wish to have their own dedicated window must have a Draw function
        setfenv(new_program.module.Draw, getfenv())
        new_program.draw_thread = coroutine.create(new_program.module.Draw)

        local prog_terminal = new_program.monitor or term.native()
        local term_w, term_h = prog_terminal.getSize()
        new_program.window = window.create(prog_terminal, 1, 1, term_w, term_h, false)

        function new_program.drawFunc()
            -- creates a fake window for the screen to freeze on while the program draws to the actual window
            -- commented out because it causes "glitchy" blinking. Should probably check for line by line differences
            -- and applying the differences from one window to the other before swapping back

            -- local frame_buffer = tableutils.deepcopy(new_program.window)
            -- new_program.window.setVisible(false)
            -- frame_buffer.setVisible(true)

            coroutine.resume(new_program.draw_thread)

            -- new_program.window.setVisible(true)
        end
    end

    function new_program.tickFunc()
        local success, msg = coroutine.resume(new_program.main_thread)
        if success == false then
            error(msg)
        end
    end

    new_program.tickFunc()                                                      -- call tick once for program initialization

    PROGRAM_LIST[new_program.name] = new_program
    return new_program
end

function Programs.open(path, arguments)

    local new_program = {}

    local file, err = loadfile(path)
    if err ~= nil then
        printf('&eProgram failed to load: "'..path..'"; error: '..err..debug.traceback())
        return
    end

    setfenv(file, getfenv())
    local success, result = pcall(file)
    if success == false then
        printf('&eProgram failed to load: "'..path..'"; error: '..result..debug.traceback())
        return
    end

    return Programs.make(result, arguments)
end

function Programs.suspend(nTime) -- TODO
    Programs.findByThread(coroutine.running()).suspended = true
end

function Programs.tick()
    while true do
        Events.dispatch()

        local program_objs = {}
        for k, v in pairs(PROGRAM_LIST) do
            if v.suspended == false then
                table.insert(program_objs, v.tickFunc)
            end
        end

        parallel.waitForAll(unpack(program_objs))

        for k, v in pairs(PROGRAM_LIST) do
            if coroutine.status(v.main_thread) == 'dead' then                   -- if program has concluded
                PROGRAM_LIST[k] = nil                                           -- remove the program from the list of running programs
            end
        end

        coroutine.yield()
    end
end

function Programs.findByThread(_thread)
    for _, v in pairs(PROGRAM_LIST) do
        if v.main_thread == _thread then
            return v
        end
    end
end

function Programs.findByName(name)
    for k, v in pairs(PROGRAM_LIST) do
        if k == name then return v end
        if v.name_pretty ~= nil and v.name_pretty == name then return v end
    end
end
