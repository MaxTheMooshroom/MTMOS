-- a Queue data structure. A modified implementaion of the source from credit.
-- credit: https://stackoverflow.com/questions/18843610/fast-implementation-of-queues-in-lua
function _G.Queue()
    local new_queue = {first = 0, last = -1}

    function new_queue.push(self, item)
        local first = self.first - 1
        self.first = first
        self[first] = item
    end

    function new_queue.pop(self)
        local last = self.last
        if self.first > last then return nil end
        local value = self[last]
        self[last] = nil         -- to allow garbage collection
        self.last = last - 1
        return value
    end

    function new_queue.size(self)
        return (self.last - self.first) + 1
    end

    return new_queue
end

-- a Stack data structure. A modified implementaion of the source from credit.
-- credit: https://stackoverflow.com/questions/18843610/fast-implementation-of-queues-in-lua
function _G.Stack()
    local new_stack = {first = 0, last = -1}

    function new_stack.push(self, item)
        local first = self.first - 1
        self.first = first
        self[first] = item
    end

    function new_stack.pop(self)
        local first = self.first
        if first > self.last then return nil end
        local value = self[first]
        self[first] = nil        -- to allow garbage collection
        self.first = first + 1
        return value
    end

    return new_stack
end
