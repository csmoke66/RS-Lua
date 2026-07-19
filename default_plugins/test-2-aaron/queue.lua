-- This file implements a queue data structure, which is a FIFO structure.

-- Set up table
Queue = {}

-- Constructor
function Queue.new ()
  return {first = 0, last = -1}
end    

-- Inserts an element at the end of the queue
function Queue.push (list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end

-- Clears all elements from the queue
function Queue.reset(list)
  for  i = 0, list.last, 1 do
    list[i] = nil
  end
  list.first = 0
  list.last = -1;
end

-- Returns element at start of queue and deletes it from queue.
function Queue.pop (list)
  local first = list.first
  if first > list.last then error("list is empty") end
  local value = list[first]
  list[first] = nil        -- to allow garbage collection
  list.first = first + 1
  return value
end

-- Returns if queue is empty
function Queue.isEmpty(list)
  return list.first > list.last 
end

return Queue