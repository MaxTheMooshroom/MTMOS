_G.Interrupts = {}
Interrupts.iq = Queue()

function Interrupts.new(_type, arguments)
    local new_interrupt = {}

    new_interrupt.uuid = UUID()
    -- TODO ...

    return new_interrupt
end

function _G.requestInterrupt(_type, args)

end
