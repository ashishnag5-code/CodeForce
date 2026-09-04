trigger AsynchronousEventTrigger on Asynchronous_Event__e (after insert) {
    AsynchronousEventTriggerHelper.handleAsyncEvents(Trigger.new);
}