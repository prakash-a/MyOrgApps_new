global class SL_LIB22_MeetingLog_Utils
{
	/* Start - Method
		Method Name: createTaskRecords
		Arguments : Map<Id, Event> - mapMLogsActivity
		Arguments : Map<String, String> - mapMeetingLogId_ActivityId
		Arguments : Sobject - objMeetingSObject
		Arguments : String - SObjectMDFieldName
		Access: GLOBAL STATIC
		Return Type: Task
		Purpose: To Create Task records
	*/
    global static Task createTaskRecords(Map<Id, Task> mapMLogsActivity, Map<String, String> mapMeetingLogId_ActivityId, Sobject objMeetingSObject, String SObjectMDFieldName)
    {
        Task objTask = new Task();
        objTask = mapMLogsActivity.get(mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).clone();
        objTask.Related_Log_Id__c = String.valueOf(objMeetingSObject.get('Id'));
        objTask.ParentTaskId__c = mapMLogsActivity.get(mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).Id;
        objTask.Status = 'Completed';
        objTask.Subject = mapMLogsActivity.get(mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).Subject;
        objTask.Description = mapMLogsActivity.get(mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).Description;
        objTask.ActivityDate = mapMLogsActivity.get(mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).ActivityDate;

        if(String.valueOf(Id.valueOf(String.valueOf(objMeetingSObject.get(SObjectMDFieldName))).getSObjectType()) == 'Contact' ||
            String.valueOf(Id.valueOf(String.valueOf(objMeetingSObject.get(SObjectMDFieldName))).getSObjectType()) == 'Lead')
        {
            objTask.WhoId = String.valueOf(objMeetingSObject.get(SObjectMDFieldName));
            objTask.WhatId = null;
        }
        else
        {
            objTask.WhoId = null;
            objTask.WhatId = String.valueOf(objMeetingSObject.get(SObjectMDFieldName));
        }

        return objTask;
    }
	/* End - Method */

	/* Start - Method
		Method Name: createEventRecords
		Arguments : Map<Id, Event> - mapMLogsEvent
		Arguments : Map<String, String> - mapMeetingLogId_ActivityId
		Arguments : Sobject - objMeetingSObject
		Arguments : String - SObjectMDFieldName
		Access: GLOBAL STATIC
		Return Type: Event
		Purpose: To Create Event records
	*/
    global static Event createEventRecords(Map<Id, Event> mapMLogsEvent, Map<String, String> mapMeetingLogId_ActivityId, Sobject objMeetingSObject, String SObjectMDFieldName)
    {
        Event objEvent = new Event();
        objEvent = mapMLogsEvent.get(mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).clone();
        objEvent.Related_Log_Id__c = String.valueOf(objMeetingSObject.get('Id'));
        objEvent.OwnerId = mapMLogsEvent.get(mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).OwnerId;
        objEvent.StartDateTime = mapMLogsEvent.get(mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).StartDateTime;
        objEvent.EndDateTime = mapMLogsEvent.get(mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).EndDateTime;
        objEvent.Subject = mapMLogsEvent.get(mapMeetingLogId_ActivityId.get(String.valueOf(objMeetingSObject.get('Meeting_Log__c')))).Subject;

        if(String.valueOf(Id.valueOf(String.valueOf(objMeetingSObject.get(SObjectMDFieldName))).getSObjectType()) == 'Contact' ||
            String.valueOf(Id.valueOf(String.valueOf(objMeetingSObject.get(SObjectMDFieldName))).getSObjectType()) == 'Lead')
        {
            objEvent.WhoId = String.valueOf(objMeetingSObject.get(SObjectMDFieldName));
            objEvent.WhatId = null;
        }
        else
        {
            objEvent.WhoId = null;
            objEvent.WhatId = String.valueOf(objMeetingSObject.get(SObjectMDFieldName));
        }
        return objEvent;
    }
	/* End - Method */

	/* Start - Method
		Method Name: readFieldSet
		Arguments : ObjectName - SObject Name
		Arguments : fieldSetName - FieldSet Name of that SObject
		Access: GLOBAL STATIC
		Return Type: List<Schema.FieldSetMember>
		Purpose: To fetch the fields from fieldset
	*/
    global static List<Schema.FieldSetMember> readFieldSet(String ObjectName, String fieldSetName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }
	/* End - Method */

	/* Start - Method
		Method Name: createMapFieldAPI_Label
		Arguments : strObjectName - SObject Name
		Arguments : strFieldSetName - FieldSet Name of that SObject
		Arguments : strOrderBy - Direction
		Arguments : strMeetingLogId - Meeting Log Id
		Access: GLOBAL STATIC
		Return Type: String
		Purpose: To create a query string for Meeting SObject
	*/
    global static String createQueryString(String strObjectName, String strFieldSetName, String strOrderBy, String strMeetingLogId)
    {
        String strFields = '';

        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet(strObjectName, strFieldSetName);
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            if(strFields == '')
            {
                if(String.valueOf(fieldSetMemberObj.getFieldPath()) != 'Meeting_Log__c' && String.valueOf(fieldSetMemberObj.getFieldPath()) != 'Id')
                    strFields += String.valueOf(fieldSetMemberObj.getFieldPath());
            }
            else
            {
                if(String.valueOf(fieldSetMemberObj.getFieldPath()) != 'Meeting_Log__c' && String.valueOf(fieldSetMemberObj.getFieldPath()) != 'Id')
                    strFields += ', ' + String.valueOf(fieldSetMemberObj.getFieldPath());
            }
        }

        String strQuery = '';
        strQuery = 'Select Id, Meeting_Log__c,  ' + strFields + ' From ' + strObjectName + ' where Meeting_Log__c = ' + '\'' + strMeetingLogId + '\'' +' ORDER BY ' + strOrderBy + ' ASC LIMIT 1000';

        return strQuery;
    }
	/* End - Method */

	/* Start - Method
		Method Name: createMapFieldAPI_Label
		Arguments : strObjectName - SObject Name
		Arguments : strFieldSetName - FieldSet Name of that SObject
		Access: GLOBAL STATIC
		Return Type: Map<String, String>
		Purpose: To create a Map of Field API Name and its Label
	*/
    global static Map<String, String> createMapFieldAPI_Label(String strObjectName, String strFieldSetName)
    {
        Map<String , String> mapFieldAPI_Label = new Map<String, String>();

        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet(strObjectName, strFieldSetName);
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            mapFieldAPI_Label.put(String.valueOf(fieldSetMemberObj.getFieldPath()), String.valueOf(fieldSetMemberObj.getLabel()));
        }

        return mapFieldAPI_Label;
    }
	/* End - Method */

	/* Start - Method
		Method Name: createListFieldAPI
		Arguments : strObjectName - SObject Name
		Arguments : strFieldSetName - FieldSet Name of that SObject
		Access: GLOBAL STATIC
		Return Type: List<String>
		Purpose: To create a List of Field API Name's list
	*/
    global static List<String> createListFieldAPI(String strObjectName, String strFieldSetName)
    {
        try
        {
            List<String> lstFieldAPI = new List<String>();

            List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet(strObjectName, strFieldSetName);
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
            {
                lstFieldAPI.add(String.valueOf(fieldSetMemberObj.getFieldPath()));
            }

            return lstFieldAPI;
        }
        catch(Exception e)
        {
            return null;
        }
    }
	/* End - Method */

	/* Start - Method
		Method Name: loadMapSObject_FieldSetData
		Access: GLOBAL STATIC
		Return Type: Map<String, String>
		Purpose: To create a map of SObject and its FieldSet Name
	*/
    global static Map<String, String> loadMapSObject_FieldSetData()
    {
    	Map<String, String> mapSObject_FieldSetName = new Map<String, String>();
        mapSObject_FieldSetName.put('MeetingAttendee__c' , 'SL_MeetingAttendee_Fieldsets');
        mapSObject_FieldSetName.put('MeetingStaff__c' , 'SL_MeetingStaff_Fieldsets');
        mapSObject_FieldSetName.put('MeetingCompany__c' , 'SL_MeetingCompany_Fieldsets');
        mapSObject_FieldSetName.put('Task' , 'SL_FollowUpTask_Fieldsets');
        return mapSObject_FieldSetName;
    }
    /* End - Method */

	/* Start - Method
		Method Name: loadMapSObject_QueryFieldData
		Access: GLOBAL STATIC
		Return Type: Map<String, String>
		Purpose: To create a map of SObject and its query field
	*/
    global static Map<String, String> loadMapSObject_QueryFieldData()
    {
    	Map<String, String> mapSObject_QueryFieldName = new Map<String, String>();
        mapSObject_QueryFieldName.put('MeetingAttendee__c' , 'Attendee__r.Name');
        mapSObject_QueryFieldName.put('MeetingStaff__c' , 'Contact__r.Name');
        mapSObject_QueryFieldName.put('MeetingCompany__c' , 'Company__r.Name');
        mapSObject_QueryFieldName.put('Task' , 'Subject');
        return mapSObject_QueryFieldName;
    }
    /* End - Method */

	/* Start - Method
		Method Name: loadMapSObject_MDFieldData
		Access: GLOBAL STATIC
		Return Type: Map<String, String>
		Purpose: To create a Map which will store the SObject Name and Master Details field
	*/
    global static Map<String, String> loadMapSObject_MDFieldData()
    {
    	Map<String, String> mapSObject_MDFieldName = new Map<String, String>();
        mapSObject_MDFieldName.put('MeetingAttendee__c' , 'Attendee__c');
        mapSObject_MDFieldName.put('MeetingStaff__c' , 'Contact__c');
        mapSObject_MDFieldName.put('MeetingCompany__c' , 'Company__c');
        mapSObject_MDFieldName.put('Task' , 'Subject');
        return mapSObject_MDFieldName;
    }
    /* End - Method */

	/* Start - Method
		Method Name: loadMapSObject_CSVFieldData
		Access: GLOBAL STATIC
		Return Type: Map<String, String>
		Purpose: To create a map of SObject and CSV Field related to it
	*/
    global static Map<String, String> loadMapSObject_CSVFieldData()
    {
    	Map<String, String> mapSObject_QueryFieldName = new Map<String, String>();
        mapSObject_QueryFieldName.put('MeetingAttendee__c' , 'Meeting_Attendee_CSV__c');
        mapSObject_QueryFieldName.put('MeetingStaff__c' , 'Meeting_Staff_CSV__c');
        mapSObject_QueryFieldName.put('MeetingCompany__c' , 'Meeting_Company_CSV__c');
        return mapSObject_QueryFieldName;
    }
	/* End - Method */

	/* Start - Method
		Method Name: fetchAllTaskFields
		Access: GLOBAL STATIC
		Return Type: String
		Purpose: To fetch all fields of Task Object
	*/
    global static String fetchAllTaskFields()
    {
    	Map<String, Schema.SObjectField> M = Schema.SObjectType.Task.fields.getMap();
        String strFields = '';
        for(Schema.SObjectField s : M.values())
        {
            strFields += String.valueOf(s)+',';
        }
        String strTaskFields = strFields.substring(0,strFields.length()-1);

        return strTaskFields;
    }
	/* End - Method */

	/* Start - Method
		Method Name: fetchAllEventFields
		Access: GLOBAL STATIC
		Return Type: String
		Purpose: To fetch all fields of Event
	*/
    global static String fetchAllEventFields()
    {
    	Map<String, Schema.SObjectField> M = Schema.SObjectType.Event.fields.getMap();
        String strFields = '';
        for(Schema.SObjectField s : M.values())
        {
            strFields += String.valueOf(s)+',';
        }
        String strEventFields = strFields.substring(0,strFields.length()-1);

        return strEventFields;
    }
	/* End - Method */

	/* Start - Method
		Method Name: fetchAllSObjectFields
		Argument : String - strSObjectName
		Access: GLOBAL STATIC
		Return Type: String
		Purpose: To fetch all fields of SObject passed as paramter
	*/
    global static String fetchAllSObjectFields(String strSObjectName)
    {
    	Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
		Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(strSObjectName);
		Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

		Map<String, schema.SobjectField> fieldsMeta = DescribeSObjectResultObj.fields.getMap();

		String strSObjectAllFields = '';
		// Looping on object field Key set to find out the blank fields
		for(Schema.SObjectField field : fieldsMeta.values())
		{
		    strSObjectAllFields += String.valueOf(field)+',';
        }

		if(strSObjectAllFields != '')
        	strSObjectAllFields = strSObjectAllFields.substring(0, strSObjectAllFields.length() - 1);

        return strSObjectAllFields;
    }
    /* End - Method */

	/* Start - Method
		Method Name: getSObjectDataForRelatedList
		Argument : String - strRelatedListName
		Argument : String - strMeetingLogId
		Access: GLOBAL STATIC
		Return Type: List<SL_LIB22_MeetingLog_GenericWrapper>
		Purpose: To fetch records for related list
	*/
    global static List<SL_LIB22_MeetingLog_GenericWrapper> getSObjectDataForRelatedList(String strRelatedListName, String strMeetingLogId)
    {
    	try
    	{
            List<SL_LIB22_MeetingLog_GenericWrapper> lstRelatedList = new List<SL_LIB22_MeetingLog_GenericWrapper>();

            String strFieldSetName = '';
            String strQueryFieldCondition = '';

            strFieldSetName = SL_LIB22_MeetingLog_Utils.loadMapSObject_FieldSetData().get(strRelatedListName);
            strQueryFieldCondition = SL_LIB22_MeetingLog_Utils.loadMapSObject_QueryFieldData().get(strRelatedListName);

            for(SObject objSObject : Database.query(SL_LIB22_MeetingLog_Utils.createQueryString(strRelatedListName, strFieldSetName , strQueryFieldCondition, strMeetingLogId)))
            {
                SL_LIB22_MeetingLog_GenericWrapper obj = new SL_LIB22_MeetingLog_GenericWrapper(objSObject);
                lstRelatedList.add(obj);
            }

            return lstRelatedList;


    	}
    	catch(Exception e)
    	{
			return null;
    	}
    }
    /* End - Method */

	/* Start - Method
		Method Name: addSObjectRow
		Argument : List<SL_LIB22_MeetingLog_GenericWrapper> - lstSObject
		Argument : String - strObjectName
		Access: GLOBAL STATIC
		Return Type: List<SL_LIB22_MeetingLog_GenericWrapper>
		Purpose: To add Row in Sobject related List
	*/
    global static List<SL_LIB22_MeetingLog_GenericWrapper> addSObjectRow(List<SL_LIB22_MeetingLog_GenericWrapper> lstSObject, String strObjectName)
    {
    	if(lstSObject.size() < 1000)
    	{
    		Sobject objSObject;
			Schema.SObjectType ObjType = Schema.getGlobalDescribe().get(strObjectName);
			objSObject = ObjType.newSobject();
            SL_LIB22_MeetingLog_GenericWrapper objInnerSobject  = new SL_LIB22_MeetingLog_GenericWrapper(objSObject);
            lstSObject.add(objInnerSobject);

            return lstSObject;

    	}
    	else
    	{
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot create more than 1000 records.');
			ApexPages.addMessage(myMsg);
			return lstSObject;
    	}
    }
	/* End - Method */

	/* Start - Method
		Method Name: deleteSObjectRecord
		Argument : List<SL_LIB22_MeetingLog_GenericWrapper> - lstSObject
		Argument : String - strObjectName
		Access: GLOBAL STATIC
		Return Type: List<SL_LIB22_MeetingLog_GenericWrapper>
		Purpose: To delete the record for SObject
	*/
    global static List<SL_LIB22_MeetingLog_GenericWrapper> deleteSObjectRecord(List<SL_LIB22_MeetingLog_GenericWrapper> lstSObject, String strSObjectId)
    {
    	for(Integer i=0; i<lstSObject.size(); i++)
        {
	    	if(lstSObject[i].isDelete && lstSObject[i].objSObject.get('Id') != null && lstSObject[i].objSObject.get('Id') == strSObjectId)
	        {
	            Sobject objSObject;
				Schema.SObjectType ObjType = Schema.getGlobalDescribe().get(String.valueOf(Id.valueOf(strSObjectId).getSObjectType()));
				objSObject = ObjType.newSobject();

				objSObject.Id = Id.valueOf(strSObjectId);

				delete objSObject;
	            lstSObject.remove(i);
	            break;
	        }
	        else if(lstSObject[i].isDelete)
	        {
	            lstSObject.remove(i);
	            break;
	        }
        }

        if(!lstSObject.isEmpty())
        	return lstSObject;
        else
        	return new List<SL_LIB22_MeetingLog_GenericWrapper>();
    }
	/* End - Method */

	/* Start - Method
		Method Name: sendEmailOnException
		Argument : Exception - e
		Access: GLOBAL STATIC
		Return Type: void
		Purpose: To send an Email alert when any exception occured
	*/
    global static void sendEmailOnException(Exception e)
    {
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		String[] toAddresses = new String[] {'rehan.dawt@trekbin.com'};

		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Mutli Connect Salesforce Support');
		mail.setSubject('MultiConnect - ERROR EMAIL ');
		mail.setPlainTextBody('Error: ' + e + 'Line Number for Assignment ' + e.getLineNumber());

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
	/* End - Method */
}