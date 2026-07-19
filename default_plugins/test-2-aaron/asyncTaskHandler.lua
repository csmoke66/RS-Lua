Queue = require("./queue")

AsyncTaskList = {}

function AsyncTaskList.New() 
    -- Internal Queue Container
    return Queue.new()
end

    -- Schedule a function onto the Queue
function AsyncTaskList.schedule (taskList,task)

        -- Input Validation to ensure task is passed in an is a function. Error out if not.
        if(type(task) ~= "function") then
            osrs.print("ERROR: Must Pass in Function. Passed in type: " .. type(task))
            return
        end

        -- Add container associating the function with its delay to the queue so it can be read during execution.
        Queue.push(taskList,task)
    end

    -- Tell Task List to start running
function AsyncTaskList.startTaskExecution (taskList)
        AsyncTaskList.runTaskList(taskList)
    end

    -- Recursive function that iterates through every queued function 
function AsyncTaskList.runTaskList (taskList)

    -- Checks if we've hit end of queue. If so, exit and reset the queue.
    if(Queue.isEmpty(taskList)) then
        Queue.reset(taskList)
        return 
    end

    -- Pop off function from queue. 
    local callback = Queue.pop(taskList)

    -- Validate that popped off element is of expected type
    if(type(callback) ~= "function") then
        osrs.print("ERROR: Callback is incorrect type. Passed in Callback type: " .. type(callback))
        return
    end

    callback(function()  AsyncTaskList.runTaskList(taskList) end)
end

return AsyncTaskList