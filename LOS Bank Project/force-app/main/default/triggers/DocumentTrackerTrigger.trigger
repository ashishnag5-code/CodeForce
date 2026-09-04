trigger DocumentTrackerTrigger on Document_Tracker__c (after insert) {
	new DocumentTrackerHandler().run('Document_Tracker__c', 'Document_Tracker_Trigger__c');
}