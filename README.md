# Swift Concurrency

## Concurrency 

### Async vs Sync

### Parallel code

## Tasks

* Are isolated from each other, which is what makes it safe for them to run at the same time
* When we need to share information between tasks: actors

### Structured Concurrency

### Unstructured Concurrency

### Threads

Hacking with Swift:

Each thread you create needs to run somewhere, and if you accidentally end up creating 40 threads when you have only 4 CPU cores, the system will need to spend a lot of time just swapping them. 
Context switch: swapping threads (has performance cost -> Thread explosion)

#### Yielding the thread

* Cooperative thread pool

### Queues

* Serial
* Concurrent

### Continuations

### Cancelattion

### Threads and retain cycles

* Tasks have implicit capturing.
* Any object used within a Task will automatically be retained until that task has finished (or failed).
* ⚠️ [weak self] + guard let self *WILL NOT WORK*
* We need to maintain self?. because local self reference will still be retained while async calls are suspended.
* (Reference)[https://www.swiftbysundell.com/articles/memory-management-when-using-async-await/]


## Actors

* Allow only one task to access their mutable state at a time (which makes it safe for code in multiple tasks to interact with the same instance of an actor)
* An actor runs only one piece of code at a time
* if you’re attempting to read a variable property or call a method on an actor, and you’re doing it from outside the actor itself, you must do so asynchronously using await.

### Actor isolation

### Actor hopping

When a thread pauses work on one actor to start work on another actor instead, we call it actor hopping, and it will happen any time one actor calls another.

## Concurrency Domain & Sendable 

* Concurrency Domain is the part of a program that contains mutable state inside of a task or an instance of an actor.

* Sendable is a type that can be shared from one concurrency domain to another (ex: as argument when calling actor method or be returned as the result of a task)

* Some types aren't safe to pass across concurrency domains. For example a class that contains mutable properties and doesn't serialize access to those properties can produce unpredictabble and incorrect results when you pass intances of that class between different tasks.

* Actors automatically conform to Sendable

 
