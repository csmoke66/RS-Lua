Queue = require("./queue")

IntervalTaskList = {}

function IntervalTaskList.New()    
-- Internal Queue Container
    return Queue.new()
end

    -- Schedule a function onto the Queue
function IntervalTaskList.schedule (taskList ,task, delay)

        -- Make delay an optional parameter. Default to no delay if not specified.
        if(delay == nil) then
            delay = 0
        end

        -- Input Validation to ensure task is passed in an is a function. Error out if not.
        if(type(task) ~= "function") then
            osrs.print("ERROR: Must Pass in Function. Passed in type: " .. type(task))
            return
        end

        -- Add container associating the function with its delay to the queue so it can be read during execution.
        Queue.push(taskList,{task, delay})
end

    -- Tell Task List to start running
function IntervalTaskList.startTaskExecution (taskList)
        IntervalTaskList.runTaskList(taskList)
end

    -- Recursive function that iterates through every queued function 
function IntervalTaskList.runTaskList(taskList)

        -- Checks if we've hit end of queue. If so, exit and reset the queue.
        if(Queue.isEmpty(taskList)) then
            Queue.reset(taskList)
            return 
        end

        -- Pop off container with function and delay from front of queue. 
        local currTask = Queue.pop(taskList)

        local callback = currTask[1]
        local delay = currTask[2]

        -- Validate that container elements are of expected type
        if(type(callback) ~= "function" or type(delay) ~= "number") then
            osrs.print("ERROR: Callback is incorrect type. Passed in Callback type: " .. type(callback) .. ", Delay type: " .. type(delay))
            return
        end

        -- Set up async call
        osrs.setInterval(
        -- Create lambda that wraps scheduled callback with recursion call. Delay call by specified seconds.
            function()
                callback()
                IntervalTaskList.runTaskList(taskList)
            end
        , delay)
    end

return IntervalTaskList