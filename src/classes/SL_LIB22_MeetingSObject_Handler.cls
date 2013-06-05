public with sharing class SL_LIB22_MeetingSObject_Handler
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    /*  Constructor*/
    public SL_LIB22_MeetingSObject_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    /*  Function for OnBeforeInsert     */
    public void OnBeforeInsert(List<SObject> lstMSObjectNew, String sObjectName, String SObjectMDFieldName)
    {
        try
        {
            Set<String> setMeetingSObject = new Set<String>(); // Set of MeetingLog and SObject Id for checking with Duplicate records.
            Set<Id> setMeetingLogIds = new Set<Id>(); // Set of Meeting Log ids to fetch all Meeting Log Records for that Meeting Log Id.
            for(SObject objMObject : lstMSObjectNew)
            {
                setMeetingLogIds.add(String.valueOf(objMObject.get('Meeting_Log__c')));
            }

            // Fetching all Meeting SObject Records to avoid all duplicate records
            String strQuery = '';
            strQuery = 'Select Meeting_Log__c, ' +  SObjectMDFieldName + ' from ' + sObjectName + ' where Meeting_Log__c IN: setMeetingLogIds';
            for(SObject objMObject : Database.query(strQuery))
            {
                setMeetingSObject.add(String.valueOf(objMObject.get('Meeting_Log__c') + '_' + String.valueOf(objMObject.get(SObjectMDFieldName))));
            }

            // Ckecking All Meeting SObject Record who are having duplicate records and showing Error Message.
            for(SObject objMObject : lstMSObjectNew)
            {
                if(setMeetingSObject.contains(String.valueOf(objMObject.get('Meeting_Log__c')) + '_'+ String.valueOf(objMObject.get(SObjectMDFieldName))))
                {
                    objMObject.addError('Duplicate Record found');
                }
                setMeetingSObject.add(String.valueOf(objMObject.get('Meeting_Log__c')) + '_'+ String.valueOf(objMObject.get(SObjectMDFieldName)));
            }
        }
        catch(Exception e)
        {
            // Do Nothing.
        }
    }

    /*  Function for OnAfterInsert      */
    public void OnAfterInsert(Map<Id, SObject> mapMSObjectNew, String sObjectName, String SObjectMDFieldName)
    {
        try
        {
            List<SL_MultiConnect__c> lstMultiConnect = new List<SL_MultiConnect__c>(); // List of Copy Task Feature records
            lstMultiConnect = [Select Sent_an_Email__c, PDF_Report__c, Name, FollowUp_Task__c, Create_Tasks__c, Create_Events__c,
                                    CopyTask__c
                                    From SL_MultiConnect__c
                                    WHERE Name = 'Multi-Connect'
                                    LIMIT 1];
            // Checking with the Copy Task feature is enable or not (Custom Settings).
            if(!lstMultiConnect.isEmpty() && lstMultiConnect[0].CopyTask__c)
            {
                Set<Id> setMLogActivityId = new Set<Id>(); // Set for storing Meeting Log Ids
                Set<String> setMeetingSObjectIds = new Set<String>(); // Set for Storing Meeting Log and SObject Ids of alreadys present in Org for Duplicate purpose
                Map<Id, Task> mapMLogsActivity = new Map<Id, Task>(); // Map of Task Records
                Map<Id, SObject> mapMeetingSObject = new Map<Id, SObject>(); // Map of Meeting SObject Records
                Map<Id, Event> mapMLogsEvent = new Map<Id, Event>(); // Map of Event Records
                List<Task> lstTask = new List<Task>();  // List for All Task Records
                List<Event> lstEvent = new List<Event>(); // List for All Event Records
                Set<Id> setMSObjectIds = new Set<Id>();
                Set<Id> setMeetingLogIds = new Set<Id>();
                Map<String, String> mapMeetingLogId_ActivityId = new Map<String, String>();

                setMSObjectIds.addAll(mapMSObjectNew.keySet());

                // fetching all Task and Event Ids which are related to Meeting SObject's.
                String strQuery = '';
                strQuery = 'Select Meeting_Log__c, Meeting_Log__r.ActivityID__c, ' + SObjectMDFieldName + ' from ' + sObjectName + ' where Id IN: setMSObjectIds ';

                for(SObject objMObject : Database.query(strQuery))
                {
                    setMeetingLogIds.add(String.valueOf(objMObject.get('Meeting_Log__c')));
                }

                for(Meeting_Log__c objMeetingLog : [Select Id, ActivityId__c from Meeting_Log__c where Id IN: setMeetingLogIds])
                {
                    mapMeetingLogId_ActivityId.put(objMeetingLog.Id, objMeetingLog.ActivityID__c);
                }

                for(SObject objMObject : Database.query(strQuery))
                {
                    setMLogActivityId.add(mapMeetingLogId_ActivityId.get(String.valueOf(objMObject.get('Meeting_Log__c'))));
                    mapMeetingSObject.put(objMObject.Id, objMObject);
                }

                // Querying all Task Ids for above Set of Ids and preparing Map.
                for(Task objTask : [Select WhoId, Subject, Status, Priority, ParentTaskId__c, Meeting_Log__c, Id, Description, CallType,
                                        CallObject, ActivityDate, AccountId
                                    From Task
                                    Where Id IN: setMLogActivityId])
                {
                    mapMLogsActivity.put(objTask.Id, objTask);
                }

                // Querying all Event Ids for above Set of Ids and preparing a Map.
                for(Event objEvent : [Select e.WhoId, e.WhatId, e.Subject, e.StartDateTime, e.ShowAs, e.Parent_Task__c, e.ParentTaskId__c, e.OwnerId,
                                      e.Meeting_Log__c, e.Location, e.EndDateTime, e.Description, e.ActivityDate, e.AccountId
                                      From Event e
                                      Where Id IN : setMLogActivityId])
                {
                    mapMLogsEvent.put(objEvent.Id, objEvent);
                }

                // Creating Task and Event based on the Activity Ids first three letters.
                for(SObject objMeetingSObject : mapMeetingSObject.values())
                {
                    // Checking for Activity Id is of Task Id.

                    if((mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).substring(0,3) == '00T')
                    {
                        if(!setMeetingSObjectIds.contains(String.valueOf(objMeetingSObject.get('Meeting_Log__c')) + '_'+ String.valueOf(objMeetingSObject.get(SObjectMDFieldName))))
                        {
                            setMeetingSObjectIds.add(String.valueOf(objMeetingSObject.get('Meeting_Log__c')) + '_'+ String.valueOf(objMeetingSObject.get(SObjectMDFieldName)));
                            Task objTask =  new Task();
                            objTask = SL_LIB22_MeetingLog_Utils.createTaskRecords(mapMLogsActivity, mapMeetingLogId_ActivityId, objMeetingSObject, SObjectMDFieldName);
                            lstTask.add(objTask);
                        }
                    } // Checking for Activity Id is of Event Id.
                    else if((mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).substring(0,3) == '00U')
                    {
                        if(!setMeetingSObjectIds.contains(String.valueOf(objMeetingSObject.get('Meeting_Log__c')) + '_'+ String.valueOf(objMeetingSObject.get(SObjectMDFieldName))))
                        {
                            setMeetingSObjectIds.add(String.valueOf(objMeetingSObject.get('Meeting_Log__c')) + '_'+ String.valueOf(objMeetingSObject.get(SObjectMDFieldName)));
                            Event objEvent = new Event();
                            objEvent = SL_LIB22_MeetingLog_Utils.createEventRecords(mapMLogsEvent, mapMeetingLogId_ActivityId, objMeetingSObject, SObjectMDFieldName);
                            lstEvent.add(objEvent);
                        }
                    }
                }

                // Inserting List of Task for Bulk Data.
                if(lstTask.size() > 0)
                    insert lstTask;

                // Inserting List of Event for Bulk Data.
                if(lstEvent.size() > 0)
                    insert lstEvent;

                // Creating CSV
                createCSVValues(setMeetingLogIds, SObjectMDFieldName, sObjectName);
            }
        }
        catch(Exception e)
        {
            // do nothing.
            system.debug('?????????????????????' + e.getMessage());
            system.debug('?????????????????????' + e.getLineNumber());
            SL_LIB22_MeetingLog_Utils.sendEmailOnException(e);
        }
    }

    /*  Function for OnAfterDelete      */
    public void OnAfterDelete(Map<Id, SObject> mapMSObjectOld)
    {
        try
        {
            List<Task> lstTask = new List<Task>();
            List<Event> lstEvent = new List<Event>();

            // Query for All Task who are having Meeting Attendee as Id in Related Log Id fiels for Delete
            for(Task objTask : [Select Id,Related_Log_Id__c from Task where Related_Log_Id__c != NULL AND Related_Log_Id__c IN: mapMSObjectOld.keySet()])
            {
                lstTask.add(objTask);
            }

            // Query for All Event who are having Meeting Attendee as Id in Related Log Id fiels for Delete
            for(Event objEvent : [Select Id,Related_Log_Id__c from Event where Related_Log_Id__c != NULL AND Related_Log_Id__c IN: mapMSObjectOld.keySet()])
            {
                lstEvent.add(objEvent);
            }

            // Deleting all Task.
            if(lstTask.size() > 0)
                delete lstTask;

            // Deleting all Event.
            if(lstEvent.size() > 0)
                delete lstEvent;
        }
        catch(Exception e)
        {
            // do nothing.
        }

    }

    private void createCSVValues(Set<Id> setMSObjectIds, String SObjectMDFieldName, String sObjectName)
    {
    	Map<String, String> mapMeetingLogID_lstMDSObjectId = new Map<String, String>();
		Map<String, String> mapId_Name = new Map<String, String>();
		Set<String> setMeetingLogId_MDSObjectId = new Set<String>();

		Set<String> setMDSObjectId = new Set<String>();

		String strQuery = '';
        strQuery = 'Select Meeting_Log__c, ' + SObjectMDFieldName + ' from ' + sObjectName + ' where Meeting_Log__c IN: setMSObjectIds ';

		String strSObjectMDFieldId = '';
    	String strSObjectMDFieldType = '';

		for(Sobject objSobject : Database.query(strQuery))
		{
		    setMeetingLogId_MDSObjectId.add(String.valueOf(objSobject.get('Meeting_Log__c')) + '_' + String.valueOf(objSobject.get(SObjectMDFieldName)));
		    setMDSObjectId.add(String.valueOf(objSobject.get(SObjectMDFieldName)));

		    if(strSObjectMDFieldId == '')
    			strSObjectMDFieldId = String.valueOf(objSobject.get(SObjectMDFieldName));
		}

		if(strSObjectMDFieldId != '')
    	{
    		strSObjectMDFieldType = String.valueOf(Id.valueOf(strSObjectMDFieldId).getSObjectType());
    	}

    	String strSObjectMDQuery = '';
        strSObjectMDQuery = 'Select Id, Name from ' + strSObjectMDFieldType + ' where Id IN: setMDSObjectId ';

		for(SObject objSObject : Database.query(strSObjectMDQuery))
		{
		    mapId_Name.put(String.valueOf(objSobject.get('Id')), String.valueOf(objSobject.get('Name')));
		}

		for(String strMeetingLogId_MDSObjectId : setMeetingLogId_MDSObjectId)
		{
		    String strMeetingLogId = '';
		    String strMDSObjectId = '';

		    strMeetingLogId = strMeetingLogId_MDSObjectId.split('_')[0];
		    strMDSObjectId = strMeetingLogId_MDSObjectId.split('_')[1];

		    if(!mapMeetingLogID_lstMDSObjectId.containsKey(strMeetingLogId))
		    {
		        mapMeetingLogID_lstMDSObjectId.put(strMeetingLogId, mapId_Name.get(strMDSObjectId));
		        system.debug('??????Does not contains?????mapMeetingLogID_lstMDSObjectId??????????' + mapMeetingLogID_lstMDSObjectId);
		    }
		    else
		    {
		        mapMeetingLogID_lstMDSObjectId.put(strMeetingLogId,(mapMeetingLogID_lstMDSObjectId.get(strMeetingLogId) + ', ' + (mapId_Name.get(strMDSObjectId))));
		    	system.debug('??????Contains?????mapMeetingLogID_lstMDSObjectId??????????' + mapMeetingLogID_lstMDSObjectId);

		    }

		}

		String strCSVField = '';
		strCSVField = SL_LIB22_MeetingLog_Utils.loadMapSObject_CSVFieldData().get(sObjectName);
		List<Meeting_Log__c> lstMeetingLogUpdate = new List<Meeting_Log__c>();

		for(String strMeetingId : mapMeetingLogID_lstMDSObjectId.keySet())
		{
		    SObject objSObject;
		    Schema.SObjectType ObjType = Schema.getGlobalDescribe().get('Meeting_Log__c');
		    objSObject = ObjType.newSobject();
		    objSObject.put('Id', Id.valueOf(strMeetingId));
		    String strCSVValue = '';
		    strCSVValue = mapMeetingLogID_lstMDSObjectId.get(strMeetingId);
		    objSObject.put(strCSVField, strCSVValue);

		    Meeting_Log__c objMeetingLog = (Meeting_Log__c) objSObject;
		    lstMeetingLogUpdate.add(objMeetingLog);
		}

		if(lstMeetingLogUpdate.size() > 0)
		update lstMeetingLogUpdate;

    	/*
    	String strQuery = '';
        strQuery = 'Select Meeting_Log__c, Meeting_Log__r.ActivityID__c, ' + SObjectMDFieldName + ' from ' + sObjectName + ' where Meeting_Log__c IN: setMSObjectIds ';

    	Set<String> setSObjectMDFieldIds = new Set<String>();
    	String strSObjectMDFieldId = '';
    	String strSObjectMDFieldType = '';
    	List<String> lstSObjectMDName = new List<String>();

    	for(Sobject objSobject : Database.query(strQuery))
    	{
    		setSObjectMDFieldIds.add(String.valueOf(objSobject.get(SObjectMDFieldName)));

    		if(strSObjectMDFieldId = '')
    			strSObjectMDFieldId = String.valueOf(objSobject.get(SObjectMDFieldName));
    	}

    	if(strSObjectMDFieldId != '')
    	{
    		strSObjectMDFieldType = String.valueOf(Id.valueOf(strSObjectMDFieldId).getSObjectType());
    	}

    	String strSObjectMDQuery = '';
        strSObjectMDQuery = 'Select Id, Name from ' + strSObjectMDFieldType + ' where Id IN: setSObjectMDFieldIds ';

    	for(SObject objSObject : Database.query(strSObjectMDQuery))
    	{
    		lstSObjectMDName.add
    	}
    	*/




    }

}