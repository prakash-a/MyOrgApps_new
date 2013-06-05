public with sharing class SL_LIB22_MeetingLog_New
{
    /* Start - Global Variables */
        public Task objTask{get;set;}//Task Object
        public Event objEvent{get;set;}//Event Object
        public Meeting_Log__c objMLog {get;set;}//Meeting Log Object

        private Boolean isBlankTask;	// used to check if the task is coming from Home tab or from any sobject record

        //SL_LIB22_MeetingLog_GenericWrapper Lists
        public list<SL_LIB22_MeetingLog_GenericWrapper> lstMAttendee {get;set;}
        public list<SL_LIB22_MeetingLog_GenericWrapper> lstMStaff {get;set;}
        public list<SL_LIB22_MeetingLog_GenericWrapper> lstMCompany {get;set;}
        public list<SL_LIB22_MeetingLog_GenericWrapper> lstFollowUpTask {get;set;}

        public list<SL_LIB22_MeetingLog_GenericWrapper> lstSObject {get;set;}

        public String selectedRelatedId {get;set;}
        public String selectedRelatedName {get;set;}
        public String strSelectRelatedTo {get;set;}

        public list<SL_MultiConnect__c> lstMultiConnect {get;set;}

        private list<Meeting_Log__c> lstMeetingLog;//Used in Save and Detail Save Method

        ////Used in Detail Save Method
        private list<MeetingAttendee__c> lstUpsertMeetingAttended;
        private list<MeetingStaff__c> lstUpsertMeetingStaff;
        private list<MeetingCompany__c> lstUpsertMeetingCompany;

        public Contact objCon {get;set;}//For Email and Phone Fields on Task

        //Boolean Variables for Error Message
        public boolean isTaskEventPresent {get;set;}
        public boolean isAttendeeError{get;set;}
        public boolean isStaffError{get;set;}
        public boolean isCompanyError{get;set;}

        public Boolean isError {get;set;}//Used to Identify Error condition for Page Redirect

        public String strCheck {get;set;} // To Identify it is Task or Event.
        private String strTaskId {get;set;}//To Identify Task Page
        public String strAddRow {get;set;}//To Add Rows
        public String strDelete {get;set;}//To Delete Rows
        private String strReturnUrl = '';//To Pass return Url for Cancel Button
        private String strWhatId = '';//To Pass What Id for New Page
        private String strWhoId = '';//To Pass Who Id for New Page
        public String strTaskLabel{get;set;}//To Pass label to Task
        public String strDuplicateDetails {get;set;}


        //Map for Copy Task Functionality
        private map<Id,Id> mapCompany;//Used for Company Copy Task
        private map<Id,Id> mapTaskComp;//Used for Company Copy Task

        //Set for Copy Task Functionality
        private Set<Id>setContact = new Set<Id>();//Used for Copy Task for both Attendee and Staff Records
        private Set<Id>setTaskCon = new Set<Id>();//Used for Copy Task for both Attendee and Staff Records

        public String strSObjectId {get;set;}

        private Map<String, Schema.SObjectType> GlobalDescribeMap;

    /* End - Global Variables */

    /* Start - Constructor */
        public SL_LIB22_MeetingLog_New()
        {
            try
            {
	            // Initialize all Global Variables.
	            InitializeForGlobalVariables();

	            GlobalDescribeMap = Schema.getGlobalDescribe();

				String strCustomSettingQueryFields = SL_LIB22_MeetingLog_Utils.fetchAllSObjectFields('SL_MultiConnect__c');

				lstMultiConnect = Database.query(' Select ' + strCustomSettingQueryFields  + ' from SL_MultiConnect__c where Name=\'' + 'Multi-Connect' + '\'');

				/*
	            lstMultiConnect = [Select Sent_an_Email__c, PDF_Report__c, Name, AutoComplete_For_RelatedList__c, Custom_Lookup_Related_To__c,
	            					FollowUp_Task__c, Create_Tasks__c, Create_Events__c, CopyTask__c
	            					From SL_MultiConnect__c
	            					WHERE Name = 'Multi-Connect'
	            					LIMIT 1];
	            */

				// To check if the Task is coming from Home Page or from any Sobject record
				if(!Apexpages.currentPage().getParameters().containsKey('what_id') && !Apexpages.currentPage().getParameters().containsKey('who_id') && !ApexPages.currentPage().getParameters().containsKey('id'))
					isBlankTask = true;

	            strCheck = Apexpages.currentPage().getParameters().get('isWhat');

				if(strCheck != '' && strCheck != NULL)
				{
					// Checking the SL_Configuration record is created or not.
					if(lstMultiConnect.size() > 0)
					{
						// Checking the Task feature is enabled or not.
						if(lstMultiConnect[0].Create_Tasks__c && strCheck == 'Task')
						{
				            if(!isBlankTask)
					        {
					            // Store all the URL Parameters Like Return URL, Task ID, WhatID and WhoID.
					            strReturnUrl = apexPages.currentPage().getParameters().get('retURL');
					            strTaskId = apexPages.currentPage().getParameters().get('id');
					            strWhatId = apexPages.currentPage().getParameters().get('what_id');
					            strWhoId = apexPages.currentPage().getParameters().get('who_id');

					            strSelectRelatedTo = 'Account';

					            // Checking the strTaskId is coming from Edit Case.
					            if(strTaskId != '' && strTaskId != null )
					            {
					                String taskFields = SL_LIB22_MeetingLog_Utils.fetchAllTaskFields();
					                List<SObject> objRecord = new List<SObject>();
					                // Fetching the record from ORG Database
					                objRecord= Database.query(' Select What.Name, ' + taskFields  + ' from Task where id=\'' + strTaskId + '\'');
					                objTask =  (objRecord.size() > 0) ? (Task)objRecord[0] : new Task();

					                selectedRelatedId = objTask.WhatId;
		                			selectedRelatedName = objTask.What.Name;

					                if(objTask.WhoId!=null)
					                {
					                     String strContact = String.valueOf(objTask.WhoId);

					                    if(strContact.startsWith('003'))
					                    {
					                        objCon = [Select Phone,Email from Contact where Contact.Id =:strContact];
					                    }
					                }
					                String strContact = String.valueOf(objTask.WhoId);

					                // Store the Meeting Log Id for an Task.
					                 List<Meeting_Log__c> lstMeetingLog = [Select Id, ActivityID__c From Meeting_Log__c where ActivityID__c  =: objTask.Id];
					                 objMLog = (!lstMeetingLog.isEmpty()) ? lstMeetingLog[0] : null;

					                if(objMLog != null)
					                {
					                    //Fetch data for related List
					                    getRelatedListData(objMLog.Id);
					                }
					            } // Checking the strTaskId is a new Button Case.
					            else if(strTaskId == '' || strTaskId == null)
					            {
					                objTask.OwnerId = UserInfo.getUserId();
					                objTask.Status = 'Completed';
					                objTask.Meeting_Log__c = true;

					                Account objAccount = new Account();
					                if(strWhatId != NULL && strWhatId != '' && strWhatId != 'null')
					                {
					                	objAccount = [Select Id, Name from Account where Id =: strWhatId];
					                }

					                if((strWhoId != null && strWhoId.startsWith('003')) || (strWhoId != null && strWhoId.startsWith('00Q')))
					                {
					                    objTask.WhoId = strWhoId;
					                	objTask.WhatId = strWhatId;

					                	selectedRelatedId = strWhatId;
		                				selectedRelatedName = objAccount.Name;
					                }
					                else
					                {
					                	selectedRelatedId = strWhatId;
		                				selectedRelatedName = objAccount.Name;
					                    objTask.WhatId = strWhatId;
					                }
					            }
					            getWhatIdInfo();
				        	}
				        	else
				        	{
				        		objTask = new Task();
				        	}
						}// Showing Message on Page for enabling the setting for Task.
						else if(!lstMultiConnect[0].Create_Tasks__c && strCheck == 'Task')
						{
							isTaskEventPresent = false;
							ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'You have not enabled settings for creating Task. You can change your settings by going here:');
							ApexPages.addMessage(myMsg);
						} // Checking the Event Feature is enabled or not.
						else if(lstMultiConnect[0].Create_Events__c && strCheck == 'Event')
						{
							if(!isBlankTask)
			            	{
			            		// Storing all values for URL in a string variable.
			            		strReturnUrl = apexPages.currentPage().getParameters().get('retURL');
					            strTaskId = apexPages.currentPage().getParameters().get('id');
					            strWhatId = apexPages.currentPage().getParameters().get('what_id');
					            strWhoId = apexPages.currentPage().getParameters().get('who_id');

					            strSelectRelatedTo = 'Account';

					            // Checking the Event Id is present or not
					            if(strTaskId != '' && strTaskId != null )
					            {
					                String eventFields = SL_LIB22_MeetingLog_Utils.fetchAllEventFields();
					                List<SObject> objRecord = new List<SObject>();
					                objRecord= Database.query(' Select What.Name, ' + eventFields  + ' from Event where id=\'' + strTaskId + '\'');
					                objEvent =  (objRecord.size() > 0) ? (Event)objRecord[0] : new Event() ;

					                selectedRelatedId = objEvent.WhatId;
		                			selectedRelatedName = objEvent.What.Name;

					                if(objEvent.WhoId!=null)
					                {
					                     String strContact = String.valueOf(objEvent.WhoId);

					                    if(strContact.startsWith('003'))
					                    {
					                        objCon = [Select Phone,Email from Contact where Contact.Id =:strContact];
					                    }
					                }
					                String strContact = String.valueOf(objEvent.WhoId);

					                // Store the Meeting Log Id for an Task.
					                 List<Meeting_Log__c> lstMeetingLog = [Select Id, ActivityID__c From Meeting_Log__c where ActivityID__c  =: objEvent.Id];
					                 objMLog = (!lstMeetingLog.isEmpty()) ? lstMeetingLog[0] : null;

					                if(objMLog != null)
					                {
					                	//Fetch data for related List
					                    getRelatedListData(objMLog.Id);
					                }
					            } // Event Id is not present and New Button is calling this code.
					            else if(strTaskId == '' || strTaskId == null)
					            {
					            	objEvent.OwnerId = UserInfo.getUserId();
					                objEvent.Meeting_Log__c = true;
					                objEvent.ShowAs = 'Busy';

					                Account objAccount = new Account();

					                if(strWhatId != NULL && strWhatId != '' && strWhatId != 'null')
						                objAccount = [Select Id, Name from Account where Id =: strWhatId];

					                if((strWhoId != null && strWhoId.startsWith('003')) || (strWhoId != null && strWhoId.startsWith('00Q')))
					                {
					                    objEvent.WhoId = strWhoId;
					                	objEvent.WhatId = strWhatId;

					                	selectedRelatedId = strWhatId;
		                				selectedRelatedName = objAccount.Name;
					                }
					                else
					                {
					                    objEvent.WhatId = strWhatId;
					                 	selectedRelatedId = strWhatId;
		                				selectedRelatedName = objAccount.Name;
					                }
					            }
					            getWhatIdInfo();
			            	}
			            	else
			            	{
			            		objEvent = new Event();
			            	}
						} // Showing Message on Page for enabling the Event Setting
						else if(!lstMultiConnect[0].Create_Events__c && strCheck == 'Event')
						{
							isTaskEventPresent = false;
							ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'You have not enabled settings for creating Event. You can change your settings by going here:');
							ApexPages.addMessage(myMsg);
						} // Showing message on Page for enabling the setting for Task or Event.
						else if(!lstMultiConnect[0].Create_Tasks__c && !lstMultiConnect[0].Create_Events__c)
						{
							isTaskEventPresent = false;
							ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'You have not enabled settings for creating Event or Task. You can change your settings by going here:');
							ApexPages.addMessage(myMsg);
						}

					} //
					else
					{
						isTaskEventPresent = true;
						ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'You have not created a custom setting record. Please create a configuration setting record');
						ApexPages.addMessage(myMsg);
					}
				}
				else
				{
					isTaskEventPresent = true;
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Please check the URL. URL is not a valid');
					ApexPages.addMessage(myMsg);
				}
            }
            catch(Exception e)
            {

            }
        }
    /* End - Constructor */

    private void getRelatedListData(String strMeetingLogId)
    {
    	// Fill Attendee Related List
        lstMAttendee = SL_LIB22_MeetingLog_Utils.getSObjectDataForRelatedList('MeetingAttendee__c', strMeetingLogId);

        // Fill Staff Related List
        lstMStaff = SL_LIB22_MeetingLog_Utils.getSObjectDataForRelatedList('MeetingStaff__c' , strMeetingLogId);

	    // Fill Company Related List
	    lstMCompany = SL_LIB22_MeetingLog_Utils.getSObjectDataForRelatedList('MeetingCompany__c', strMeetingLogId);

		if(lstMultiConnect.size() > 0 && lstMultiConnect[0].FollowUp_Task__c)
		{
            //Fill FollowUpTask Related List
            lstFollowUpTask = getDataForRelatedList('FollowUpTask');
		}
    }

    /* Start - Function to fetch WhatId and WhoId while creating new Event and Displaying it in NewEvent Page along with Custom Label*/
        public void getWhatIdInfo()
        {
        	try
        	{
	            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
	            Map<String,String> keyPrefixMap = new Map<String,String>{};
	            Set<String> keyPrefixSet = gd.keySet();
	            for(String sObj : keyPrefixSet)
	            {
	                Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
	                String tempName = r.getName();
	                String tempPrefix = r.getKeyPrefix();
	                keyPrefixMap.put(tempPrefix,tempName);
	            }
	            String strObject = '';
	            String strPrefix = '';

	            if(strCheck == 'Task')
	            {
		            if(strWhatId != null && strWhatId != '')
		                strPrefix = strWhatId.subString(0,3);
		            else if(strWhoId != null && strWhoId != '')
		                strPrefix = strWhoId.subString(0,3);
		            else if(objTask.WhatId != null)
		                strPrefix = String.valueOf(objTask.WhatId).subString(0,3);
		            else if(objTask.WhoId != null)
		                strPrefix = String.valueOf(objTask.WhoId).subString(0,3);

		            strObject = keyPrefixMap.get(strPrefix);

		            SObject objRecord;
		            String strFieldName = '';
		            if(strObject == 'Case')
		                strFieldName = 'CaseNumber';
		            else if(strObject == 'Contract')
		                strFieldName = 'ContractNumber';
		            else
		                strFieldName = 'Name';
		            if(strWhatId != null && strWhatId != '')
		                objRecord = Database.query('select ' + strFieldName + ' from '+ strObject + ' where id =:strWhatId' );
		            else if(strWhoId != null && strWhoId != '')
		                objRecord = Database.query('select ' + strFieldName + ' from '+ strObject + ' where id =:strWhoId' );
		            else if(objTask.WhatId != null)
		                objRecord = Database.query('select ' + strFieldName + ' from '+ strObject + ' where id =\'' + objTask.WhatId +'\'');
		            else if(objTask.WhoId != null)
		                objRecord = Database.query('select ' + strFieldName + ' from '+ strObject + ' where id =\'' + objTask.WhoId + '\'');

		            strTaskLabel = objRecord != null ?  string.Valueof(objRecord.get(strFieldName)) : '';
	            }
	            else if(strCheck == 'Event')
	            {
	            	if(strWhatId != null && strWhatId != '')
		                strPrefix = strWhatId.subString(0,3);
		            else if(strWhoId != null && strWhoId != '')
		                strPrefix = strWhoId.subString(0,3);
		            else if(objEvent.WhatId != null)
		                strPrefix = String.valueOf(objEvent.WhatId).subString(0,3);
		            else if(objEvent.WhoId != null)
		                strPrefix = String.valueOf(objEvent.WhoId).subString(0,3);

		            strObject = keyPrefixMap.get(strPrefix);

		            SObject objRecord;
		            String strFieldName = '';
		            if(strObject == 'Case')
		                strFieldName = 'CaseNumber';
		            else if(strObject == 'Contract')
		                strFieldName = 'ContractNumber';
		            else
		                strFieldName = 'Name';
		            if(strWhatId != null && strWhatId != '')
		                objRecord = Database.query('select ' + strFieldName + ' from '+ strObject + ' where id =:strWhatId' );
		            else if(strWhoId != null && strWhoId != '')
		                objRecord = Database.query('select ' + strFieldName + ' from '+ strObject + ' where id =:strWhoId' );
		            else if(objEvent.WhatId != null)
		                objRecord = Database.query('select ' + strFieldName + ' from '+ strObject + ' where id =\'' + objEvent.WhatId +'\'');
		            else if(objEvent.WhoId != null)
		                objRecord = Database.query('select ' + strFieldName + ' from '+ strObject + ' where id =\'' + objEvent.WhoId + '\'');

		            strTaskLabel = objRecord != null ?  string.Valueof(objRecord.get(strFieldName)) : '';
	            }
        	}
        	catch(Exception e)
        	{
        		// do nothing
        	}

        }
    /* End - WhatIdName */

    /* Start - Function to Initialize all the Global Variables */
        public void InitializeForGlobalVariables()
        {
            objTask = new Task();
            objEvent = new Event();
            objMLog = new Meeting_Log__c();
            objCon = new Contact ();

            isTaskEventPresent = true;
            isError = false;
            isAttendeeError = false;
            isStaffError = false;
            isCompanyError = false;

            lstMAttendee = new list<SL_LIB22_MeetingLog_GenericWrapper>();
            lstMStaff = new list<SL_LIB22_MeetingLog_GenericWrapper>();
            lstMCompany = new list<SL_LIB22_MeetingLog_GenericWrapper>();
            lstFollowUpTask = new list<SL_LIB22_MeetingLog_GenericWrapper>();

            //lstFollowTaskFeature = new list<SL_FollowUpTask__c>();
            //lstFeaturesEnabled = new List<SL_TaskEvent__c>();

            lstMultiConnect = new List<SL_MultiConnect__c>();

            mapCompany = new map<Id,Id>();
            mapTaskComp = new map<Id,Id>();

            strCheck = '';
            strAddRow = '';
            strDelete ='';
            strTaskLabel = '';
            strDuplicateDetails = '';
            strSObjectId = '';
            isBlankTask = false;

            selectedRelatedId = '';
            selectedRelatedName = '';
            strSelectRelatedTo = '';
        }
    /* End - Function to Initialize all the Global Variables */

    /* Start - Function Fill Related Lists */
    public List<SL_LIB22_MeetingLog_GenericWrapper> getDataForRelatedList(String strRelatedListName)
    {
    	try
    	{
            List<SL_LIB22_MeetingLog_GenericWrapper> lstRelatedList = new List<SL_LIB22_MeetingLog_GenericWrapper>();
            if(strRelatedListName == 'FollowUpTask')
            {
            	if(strCheck == 'Task')
            	{
            		String taskFields = SL_LIB22_MeetingLog_Utils.fetchAllTaskFields();

            		for(Task objFollowTask : Database.query(' Select ' + taskFields  + ' from Task where Meeting_Log__c = false AND ParentTaskId__c = ' +  '\'' + objTask.Id + '\'' + ' ORDER BY Subject Limit 1000'))
	            	{
	            		SL_LIB22_MeetingLog_GenericWrapper obj = new SL_LIB22_MeetingLog_GenericWrapper(objFollowTask);
	            		lstRelatedList.add(obj);
	            	}
            	}
            	else if(strCheck == 'Event')
            	{
	                String taskFields = SL_LIB22_MeetingLog_Utils.fetchAllTaskFields();

            		for(Task objFollowTask : Database.query(' Select ' + taskFields  + ' from Task where Meeting_Log__c = false AND ParentTaskId__c = ' +  '\'' + objEvent.Id + '\'' + ' ORDER BY Subject Limit 1000'))
	            	{
	            		SL_LIB22_MeetingLog_GenericWrapper obj = new SL_LIB22_MeetingLog_GenericWrapper(objFollowTask);
	            		lstRelatedList.add(obj);
	            	}
            	}
            }
            return lstRelatedList;
    	}
    	catch(Exception e)
    	{
    		return null;
    	}
    }

    /* Start - Function Function RedirectTaskEdit */
    	 public PageReference RedirectTaskEdit()
    	 {
    	 	try
    	 	{
	    	 	String pageRefParam = '';
	    	 	if(objTask.Meeting_Log__c == true)
	    	 	{
			 		pageRefParam = '/apex/SL_LIB22_MeetingLog_New?id='+ objTask.Id+'isWhat=Task';
			    	PageReference objPageRef = new PageReference(pageRefParam);
			       	objPageRef.setRedirect(true);
			        return objPageRef;
	    	 	}
	    	 	else
	    	 	{
	 				PageReference newPage;
	 				newPage = new PageReference('/' + strTaskId + '/e' + '?retURL=' + strReturnUrl);
	            	newPage.getParameters().put('nooverride', '1');
	    	 		return newPage.setRedirect(true);
	    	 	}
    	 	}
    	 	catch(Exception e)
    	 	{
    	 		// do nothing
    	 		return null;
    	 	}
    	 }

    /* End - Function RedirectTaskEdit */

    /* Start - Function Function RedirectTaskEdit */
    	 public PageReference RedirectEventEdit()
    	 {
    	 	try
    	 	{
	    	 	String pageRefParam = '';
	    	 	if(objEvent.Meeting_Log__c == true)
	    	 	{
			 		pageRefParam = '/apex/SL_LIB22_MeetingLog_New?id='+ objEvent.Id+'isWhat=Event';
			    	PageReference objPageRef = new PageReference(pageRefParam);
			       	objPageRef.setRedirect(true);
			        return objPageRef;
	    	 	}
	    	 	else
	    	 	{
	 				PageReference newPage;
	 				newPage = new PageReference('/' + strTaskId + '/e' + '?retURL=' + strReturnUrl);
	            	newPage.getParameters().put('nooverride', '1');
	    	 		return newPage.setRedirect(true);
	    	 	}
    	 	}
    	 	catch(Exception e)
    	 	{
    	 		// do nothing
    	 		return null;
    	 	}

    	 }

    /* End - Function RedirectTaskEdit */

     /* Start - Function Function RedirectTaskDetail */
    	 public PageReference RedirectTaskDetail()
    	 {
    	 	try
    	 	{
	    	 	String pageRefParam = '';
	    	 	if(objTask.Meeting_Log__c == true)
	    	 	{
			 		pageRefParam = '/apex/SL_LIB22_MeetingLog_Detail?id='+ objTask.Id+'isWhat=Task' ;
			    	PageReference objPageRef = new PageReference(pageRefParam);
			       	objPageRef.setRedirect(true);
			        return objPageRef;
	    	 	}
	    	 	else
	    	 	{
	 				PageReference newPage;
	 				newPage = new PageReference('/' + strTaskId + '?retURL=' + strReturnUrl);
	            	newPage.getParameters().put('nooverride', '1');
	    	 		return newPage.setRedirect(true);
	    	 	}
    	 	}
    	 	catch(Exception e)
    	 	{
    	 		// do nothing
    	 		return null;
    	 	}
    	 }

    /* End - Function RedirectTaskDetail */

    /* Start - Function Function RedirectTaskDetail */
    	 public PageReference RedirectEventDetail()
    	 {
    	 	try
    	 	{
	    	 	String pageRefParam = '';
	    	 	if(objEvent.Meeting_Log__c == true)
	    	 	{
			 		pageRefParam = '/apex/SL_LIB22_MeetingLog_Detail?id='+ objEvent.Id+'isWhat=Event' ;
			    	PageReference objPageRef = new PageReference(pageRefParam);
			       	objPageRef.setRedirect(true);
			        return objPageRef;
	    	 	}
	    	 	else
	    	 	{
	 				PageReference newPage;
	 				newPage = new PageReference('/' + strTaskId + '?retURL=' + strReturnUrl);
	            	newPage.getParameters().put('nooverride', '1');
	    	 		return newPage.setRedirect(true);
	    	 	}
    	 	}
    	 	catch(Exception e)
    	 	{
    	 		// do nothing
    	 		return null;
    	 	}
    	 }

    /* End - Function RedirectTaskDetail */

    public List<SL_LIB22_MeetingLog_GenericWrapper> addSObjectRow(List<SL_LIB22_MeetingLog_GenericWrapper> lstSObject, String strObjectName)
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
			return null;
    	}
    }


    /* Start - Function to add a New Row for Attendee, Staff, Company, Opportunity*/
        public void addRow()
        {
        	try
        	{
	            if(strAddRow == 'Attendee')
	            {
	            	if(lstMAttendee.size() < 1000)
	            	{
		                SL_LIB22_MeetingLog_GenericWrapper objInnerAttendee  = new SL_LIB22_MeetingLog_GenericWrapper(new MeetingAttendee__c());
		                lstMAttendee.add(objInnerAttendee);
	            	}
	            	else
	            	{
	            		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot create more than 1000 records.');
						ApexPages.addMessage(myMsg);
	            	}

	            }
	            else if(strAddRow == 'Staff')
	            {
	            	if(lstMStaff.size() < 1000)
	            	{
		                SL_LIB22_MeetingLog_GenericWrapper objInnerStaff = new SL_LIB22_MeetingLog_GenericWrapper(new MeetingStaff__c());
		                lstMStaff.add(objInnerStaff);
	            	}
	            	else
	            	{
	            		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot create more than 1000 records.');
						ApexPages.addMessage(myMsg);
	            	}
	            }
	            else if(strAddRow == 'Company')
	            {
	            	if(lstMCompany.size() < 1000)
	            	{
		                SL_LIB22_MeetingLog_GenericWrapper objInnerCompany = new SL_LIB22_MeetingLog_GenericWrapper(new MeetingCompany__c());
		                lstMCompany.add(objInnerCompany);
	            	}
	            	else
	            	{
	            		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot create more than 1000 records.');
						ApexPages.addMessage(myMsg);
	            	}
	            }
	            else if(strAddRow == 'FollowUpTask')
	            {
	            	if(lstFollowUpTask.size() < 1000)
	            	{
	            		if(strCheck == 'Task')
	            		{
			            	if(objTask != null)
			            	{
			            		Task objFollowUpTask = new Task();
			            		objFollowUpTask.Subject = objTask.Subject;
			            		objFollowUpTask.OwnerId = objTask.OwnerId;
			            		objFollowUpTask.Status = 'Not Started';
			            		objFollowUpTask.WhatId = objTask.WhatId;
			            		SL_LIB22_MeetingLog_GenericWrapper objInnerFollowTask = new SL_LIB22_MeetingLog_GenericWrapper(objFollowUpTask);
			            		lstFollowUpTask.add(objInnerFollowTask);
			            	}
	            		}
	            		else if(strCheck == 'Event')
	            		{
	            			if(objEvent != NULL)
	            			{
	            				Task objFollowUpTask = new Task();
			            		objFollowUpTask.Subject = objEvent.Subject;
			            		objFollowUpTask.OwnerId = objEvent.OwnerId;
			            		objFollowUpTask.Status = 'Not Started';
			            		objFollowUpTask.WhatId = objEvent.WhatId;
			            		SL_LIB22_MeetingLog_GenericWrapper objInnerFollowTask = new SL_LIB22_MeetingLog_GenericWrapper(objFollowUpTask);
			            		lstFollowUpTask.add(objInnerFollowTask);
	            			}
	            		}
	            	}
	            	else
	            	{
	            		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot create more than 1000 records.');
						ApexPages.addMessage(myMsg);
	            	}
	            }
        	}
        	catch(Exception e)
        	{
        		// do nothing
        	}
        }
    /* End - Function to add a New Row for Attendee, Staff, Company, Opportunity */

    /* Start - Function to add a New Row for Attendee, Staff, Company, Opportunity */
    public PageReference SaveRedirect()
    {
    	SavePoint savePoint;
        try
        {
            isError = false;
            String pageRefParam = '';
            Meeting_Log__c objMaster = new Meeting_Log__c();

            // Save Task.
            if(!validateErrors())
            {
            	savePoint = Database.setSavepoint();

            	if(strCheck == 'Task')
                	saveTask();
                else if(strCheck == 'Event')
                	saveEvent();

                // Save Meeting Log.
                objMaster = saveMeetingLog();

                // Save Meeting Attendee.
                saveMAttendees(objMaster);

                // Save Meeting Staff.
                saveMStaff(objMaster);

                // Save Meeting Company.
                saveMCompanies(objMaster);

				if(lstMultiConnect.size() > 0 && lstMultiConnect[0].FollowUp_Task__c)
				{
	                //Save FollowUp Task.
	                saveFollowUpTask(objMaster);
				}
                // Assign ParentId value
                assignParentId();

                //Call Copy Task function

                //Save Page Redirect
                if(strCheck == 'Task')
                	pageRefParam = '/apex/SL_LIB22_MeetingLog_Detail?id='+ objTask.Id+'&isWhat=Task';
                else if(strCheck == 'Event')
                	pageRefParam = '/apex/SL_LIB22_MeetingLog_Detail?id='+ objEvent.Id+'&isWhat=Event';
                PageReference objPageRef = new PageReference(pageRefParam);
                objPageRef.setRedirect(true);
                return objPageRef;
            }
            else
                return null;
        }

        catch(Exception e)
        {
        	Database.rollback(savePoint);
        	e.getMessage();
        	SL_LIB22_MeetingLog_Utils.sendEmailOnException(e);
            return null;
        }
    }

    /* Start - Save Task */
        public void saveTask()
        {
            if(objTask != null)
            {
                objTask.WhatId = selectedRelatedId;
                upsert objTask;
            }
        }
    /* End - Save Task */

    /* Start - Save Event*/

    	public void saveEvent()
    	{
    		if(objEvent != NULL)
    		{
    			objEvent.ActivityDateTime = objEvent.StartDateTime;

				Long secondsBetween = objEvent.EndDateTime.getTime() - objEvent.StartDateTime.getTime();
				Integer minutes = Integer.valueOf(secondsBetween / 60000);
				objEvent.DurationInMinutes = minutes;

				objEvent.WhatId = selectedRelatedId;

    			upsert objEvent;
    		}
    	}

    /* End - Save Event*/

    /* Start - Function Assign TestParent__c TaskId*/
        public void assignParentId()
        {
        	if(strCheck == 'Task')
        	{
	            if(objTask != null)
	            {
	                if(objTask.ParentTaskId__c == null)
	                	objTask.ParentTaskId__c = objTask.Id;
	                upsert objTask;
	            }
        	}
        	else if(strCheck == 'Event')
        	{
        		if(objEvent != null)
        		{
        			if(objEvent.ParentTaskId__c == null)
	                	objEvent.ParentTaskId__c = objEvent.Id;
	                upsert objEvent;
        		}
        	}

        }

    /* Start - Save Meeting Log */
        public Meeting_Log__c saveMeetingLog()
        {
            List<Meeting_Log__c> lstMeetingLog = new List<Meeting_Log__c>();
            Meeting_Log__c objMeetingLog = new Meeting_Log__c();
            if(strCheck == 'Task')
            {
	            lstMeetingLog = [Select Id, ActivityID__c From Meeting_Log__c where ActivityID__c  =: objTask.Id limit 1];
	        	if(!lstMeetingLog.isEmpty() && lstMeetingLog[0].Id != null)
	                objMeetingLog = lstMeetingLog[0];
            }
	        else if(strCheck == 'Event')
	        {
	        	lstMeetingLog = [Select Id, ActivityID__c From Meeting_Log__c where ActivityID__c  =: objEvent.Id limit 1];
	            if(!lstMeetingLog.isEmpty() && lstMeetingLog[0].Id != null)
	                objMeetingLog = lstMeetingLog[0];
	        }
            return objMeetingLog;
        }
    /* End - Meeting Log */



    /* Start - Save Attendees */
        public void saveMAttendees(Meeting_Log__c objMaster)
        {
            List<MeetingAttendee__c> lstUpdateMeetingAttended = new List<MeetingAttendee__c>();
            List<SObject> lstInsertMeetingAttended = new List<SObject>();

            for(SL_LIB22_MeetingLog_GenericWrapper obj : lstMAttendee)
            {
                if(obj.objSObject.get('Meeting_Log__c') != null)
                {
                	MeetingAttendee__c objMeetingAttendee = (MeetingAttendee__c) obj.objSObject;
                    lstUpdateMeetingAttended.add(objMeetingAttendee);
                }
                else
                {
                    obj.objSObject.put('Meeting_Log__c', objMaster.Id);

                    if(obj.strSObjectId != NULL && obj.strSObjectId != '')
                    	obj.objSObject.put('Attendee__c', obj.strSObjectId);
                    lstInsertMeetingAttended.add(obj.objSObject);
                }
            }
            if(lstUpdateMeetingAttended.size() > 0)
                update lstUpdateMeetingAttended;

            if(lstInsertMeetingAttended.size() > 0)
                insert lstInsertMeetingAttended;
        }
    /* End - Save Attendees */

    /* Start - Save Staff */
        public void saveMStaff(Meeting_Log__c objMaster)
        {
            List<MeetingStaff__c> lstUpdateMeetingStaff = new List<MeetingStaff__c>();
            List<SObject> lstInsertMeetingStaff = new List<SObject>();

            for( SL_LIB22_MeetingLog_GenericWrapper obj : lstMStaff)
            {
                if(obj.objSObject.get('Meeting_Log__c') != null)
                {
                    MeetingStaff__c objMeetingStaff = (MeetingStaff__c) obj.objSObject;
                    lstUpdateMeetingStaff.add(objMeetingStaff);
                }
                else
                {
                    obj.objSObject.put('Meeting_Log__c', objMaster.Id);
                    if(obj.strSObjectId != NULL && obj.strSObjectId != '')
                    	obj.objSObject.put('Contact__c', obj.strSObjectId);
                    lstInsertMeetingStaff.add(obj.objSObject);
                }
            }
            if(lstUpdateMeetingStaff.size() > 0)
                update lstUpdateMeetingStaff;

            if(lstInsertMeetingStaff.size() > 0)
            	insert lstInsertMeetingStaff;
        }
    /* End - Save Staff */

    /* Start - Save Companies */
        public void saveMCompanies(Meeting_Log__c objMaster)
        {
            List<MeetingCompany__c> lstUpdateMeetingCompany = new List<MeetingCompany__c>();
            List<SObject> lstInsertMeetingCompany = new List<SObject>();

            for( SL_LIB22_MeetingLog_GenericWrapper obj : lstMCompany)
            {
                if(obj.objSObject.get('Meeting_Log__c') != null)
                {
                    MeetingCompany__c objMeetingCompany = (MeetingCompany__c) obj.objSObject;
                    lstUpdateMeetingCompany.add(objMeetingCompany);
                }
                else
                {
                    obj.objSObject.put('Meeting_Log__c', objMaster.Id);

                    if(obj.strSObjectId != NULL && obj.strSObjectId != '')
                    	obj.objSObject.put('Company__c', obj.strSObjectId);
                    lstInsertMeetingCompany.add(obj.objSObject);
                }
            }
            if(lstUpdateMeetingCompany.size() > 0)
                update lstUpdateMeetingCompany;

            if(lstInsertMeetingCompany.size() > 0)
                insert lstInsertMeetingCompany;
        }
    /* End - Save Companies */

    /* Start - saveFollowUpTask */

    	public void saveFollowUpTask(Meeting_Log__c objMaster)
    	{

    		List<Task> lstUpdateFollowUpTask = new List<Task>();
    		List<SObject> lstInsertFollowUpTask = new List<SObject>();
    		for(SL_LIB22_MeetingLog_GenericWrapper obj : lstFollowUpTask)
    		{
    			if(obj.objSObject.get('ParentTaskId__c') != null)
    			{
    				Task objTask = (Task) obj.objSObject;
    				lstUpdateFollowUpTask.add(objTask);
    			}
    			else
    			{
    				if(strCheck == 'Task')
    				{
	    				obj.objSObject.put('ParentTaskId__c' , objTask.Id);
	    				lstInsertFollowUpTask.add(obj.objSObject);
    				}
    				else if(strCheck == 'Event')
    				{
    					obj.objSObject.put('ParentTaskId__c', objEvent.Id);
	    				lstInsertFollowUpTask.add(obj.objSObject);
    				}
    			}
    		}

			if(lstUpdateFollowUpTask.size() > 0)
                update lstUpdateFollowUpTask;

    		if(lstInsertFollowUpTask.size() > 0)
                insert lstInsertFollowUpTask;
    	}

    /* End - saveFollowUpTask */

    /* Start - Validate */
        public Boolean validateErrors()
        {
            Set<String> setAttendee = new Set<String>();
            Set<String> setStaff = new Set<String>();
            Set<String> setCompany = new Set<String>();
            Set<String> setOpportunity = new Set<String>();

            Set<String> setContactId = new Set<String>();
			Map<String, String> mapContact = new Map<String, String>();

			Set<String> setAccountIds = new Set<String>();
            Map<String, String> mapAccount = new Map<String, String>();

			try
			{
				if(objTask != null)
	            {
	            	if(objTask.RecurrenceStartDateOnly > objTask.RecurrenceEndDateOnly)
	            	{
	            		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Start Date should not be greater than End Date. Please Enter Proper Start Date and End Date');
						ApexPages.addMessage(myMsg);
	            		isError = true;
	            	}
	            }

				if(objEvent != null)
	            {
	            	if(objEvent.StartDateTime > objEvent.EndDateTime)
	            	{
	            		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Start Date should not be greater than End Date. Please Enter Proper Start Date and End Date');
						ApexPages.addMessage(myMsg);
	            		isError = true;
	            	}
	            }

				for(SL_LIB22_MeetingLog_GenericWrapper obj : lstMAttendee)
				{
					if(obj.objSObject.get('Attendee__c') != NULL)
						setContactId.add(String.valueof(obj.objSObject.get('Attendee__c')));

					if(obj.strSObjectId != NULL && obj.strSObjectId != '')
						setContactId.add(obj.strSObjectId);
				}

				for(SL_LIB22_MeetingLog_GenericWrapper obj : lstMStaff)
				{
					if(obj.objSObject.get('Contact__c') != NULL)
						setContactId.add(String.valueof(obj.objSObject.get('Contact__c')));

					if(obj.strSObjectId != NULL && obj.strSObjectId != '')
						setContactId.add(obj.strSObjectId);

				}

				for(Contact objContact : [Select Id, Name from Contact where Id IN: setContactId])
				{
					mapContact.put(objContact.Id, objContact.Name);
				}

				strDuplicateDetails = '';
	            for(SL_LIB22_MeetingLog_GenericWrapper obj : lstMAttendee)
	            {
	                if(obj.objSObject.get('Attendee__c') != null && !setAttendee.contains(String.valueof(obj.objSObject.get('Attendee__c'))))
	                    setAttendee.add(String.valueof(obj.objSObject.get('Attendee__c')));
	                else if(obj.strSObjectId != NULL && obj.strSObjectId != '' && !setAttendee.contains(obj.strSObjectId))
	                	setAttendee.add(obj.strSObjectId);
	                else
	                {
	                    isAttendeeError = true;
	                    isError = true;
	                    if(obj.objSObject.get('Attendee__c') != NULL)
	                    	strDuplicateDetails = strDuplicateDetails + mapContact.get(String.valueof(obj.objSObject.get('Attendee__c'))) + ', ';
	                    else
	                    	strDuplicateDetails = strDuplicateDetails + mapContact.get(obj.strSObjectId) + ', ';
	                }
	            }

	            if(strDuplicateDetails.length() > 2)
	            	strDuplicateDetails = strDuplicateDetails.substring(0, strDuplicateDetails.length() -2);

	            if(!isAttendeeError)
	            {
		            strDuplicateDetails = '';

	                for( SL_LIB22_MeetingLog_GenericWrapper obj : lstMStaff)
	                {
	                    if(obj.objSObject.get('Contact__c') != null && !setStaff.contains(String.valueof(obj.objSObject.get('Contact__c'))))
	                        setStaff.add(String.valueof(obj.objSObject.get('Contact__c')));
	                    else if(obj.strSObjectId != NULL && obj.strSObjectId != '' && !setStaff.contains(obj.strSObjectId))
	                		setStaff.add(obj.strSObjectId);
	                    else
	                    {
	                        isStaffError = true;
	                        isError = true;
	                        if(obj.objSObject.get('Contact__c') != NULL)
	                        	strDuplicateDetails = strDuplicateDetails + mapContact.get(String.valueof(obj.objSObject.get('Contact__c'))) + ', ';
	                        else
	                    		strDuplicateDetails = strDuplicateDetails + mapContact.get(obj.strSObjectId) + ', ';
	                    }
	                }

	                if(strDuplicateDetails.length() > 2)
	            		strDuplicateDetails = strDuplicateDetails.substring(0, strDuplicateDetails.length() -2);

	            }
	            if(!isAttendeeError && !isStaffError)
	            {
	            	setCompany = new Set<String>();
	            	mapAccount = new Map<String, String>();
	            	strDuplicateDetails = '';
	            	for(SL_LIB22_MeetingLog_GenericWrapper obj : lstMCompany)
	            	{
	            		if(obj.objSObject.get('Company__c') != NULL)
	            			setAccountIds.add(String.valueof(obj.objSObject.get('Company__c')));
	            		else if(obj.strSObjectId != NULL && obj.strSObjectId != '' && !setAccountIds.contains(obj.strSObjectId))
	                		setAccountIds.add(obj.strSObjectId);

	            	}

	            	for(Account objAccount : [Select Id, Name from Account where Id IN: setAccountIds])
	            	{
	            		mapAccount.put(objAccount.Id, objAccount.Name);
	            	}

	                for( SL_LIB22_MeetingLog_GenericWrapper obj : lstMCompany)
	                {
	                    if(obj.objSObject.get('Company__c') != null && !setCompany.contains(String.valueof(obj.objSObject.get('Company__c'))))
	                        setCompany.add(String.valueof(obj.objSObject.get('Company__c')));
	                    else if(obj.strSObjectId != NULL && obj.strSObjectId != '' && !setCompany.contains(obj.strSObjectId))
	                		setCompany.add(obj.strSObjectId);
	                   else
	                    {
	                        isCompanyError = true;
	                        isError = true;
	                        if(obj.objSObject.get('Company__c') != NULL)
	                        	strDuplicateDetails += mapAccount.get(String.valueof(obj.objSObject.get('Company__c'))) + ', ';
	                        else
	                    		strDuplicateDetails = strDuplicateDetails + mapAccount.get(obj.strSObjectId) + ', ';
	                    }
	                }

	                if(strDuplicateDetails.length() > 2)
	            		strDuplicateDetails = strDuplicateDetails.substring(0, strDuplicateDetails.length() -2);
	            }

	            return isError;
			}
			catch(exception e)
			{
				// do nothng
				return isError;
			}

			return false;
        }
    /* End - Validate */

    /* Start - Cancel Button Method */
        public PageReference mainCancel()
        {
        	try
        	{
	            String pageRefParam = '';
	            if(strCheck == 'Task')
	            {
					if(!isBlankTask)
					{
						if(strTaskId =='' || strTaskId == null)
				    	{
				    		pageRefParam = strReturnUrl;
				    		PageReference objPageRef = new PageReference(pageRefParam);
				        	objPageRef.setRedirect(true);
				        	return objPageRef;
				    	}
				    	else
				    	{
				    		pageRefParam = '/apex/SL_LIB22_MeetingLog_Detail?id='+ objTask.Id + '&isWhat=Task';
				    		PageReference objPageRef = new PageReference(pageRefParam);
				       	 	objPageRef.setRedirect(true);
				        	return objPageRef;
				    	}
					}
					else
					{
						pageRefParam = '/home/home.jsp';
						PageReference objPageRef = new PageReference(pageRefParam);
				       	objPageRef.setRedirect(true);
				        return objPageRef;
					}
	            }
	            else if(strCheck == 'Event')
	            {
	            	if(!isBlankTask)
					{
						if(strTaskId =='' || strTaskId == null)
				    	{
				    		pageRefParam = strReturnUrl;
				    		PageReference objPageRef = new PageReference(pageRefParam);
				        	objPageRef.setRedirect(true);
				        	return objPageRef;
				    	}
				    	else
				    	{
				    		pageRefParam = '/apex/SL_LIB22_MeetingLog_Detail?id='+ objEvent.Id + '&isWhat=Event';
				    		PageReference objPageRef = new PageReference(pageRefParam);
				       	 	objPageRef.setRedirect(true);
				        	return objPageRef;
				    	}
					}
					else
					{
						pageRefParam = '/home/home.jsp';
						PageReference objPageRef = new PageReference(pageRefParam);
				       	objPageRef.setRedirect(true);
				        return objPageRef;
					}
	            }
	            return null;
        	}
        	catch(Exception e)
        	{
        		// do nothing
        		return null;
        	}
        }
    /* End - Cancel Button Method */

    public void callDummy()
    {

    }

    /* Start - Delete Records */
    public void deleteRecord()
    {
    	try
    	{
            //Delete Attendee Record
            if(strDelete == 'Attendee')
            {
                isAttendeeError = false;
                for(Integer i=0;i<lstMAttendee.size();i++)
                {
                    if(lstMAttendee[i].isDelete && lstMAttendee[i].objSObject.Id != null)
                    {

                        delete new MeetingAttendee__c(Id=lstMAttendee[i].objSObject.Id);
                        lstMAttendee.remove(i);
                        break;
                    }
                    else if(lstMAttendee[i].isDelete)
                    {
                        lstMAttendee.remove(i);
                        break;
                    }
                }
            }
            //Delete Staff Record
            else if(strDelete == 'Staff')
            {
                isStaffError = false;
                for(Integer i=0;i<lstMStaff.size();i++)
                {
                    if(lstMStaff[i].isDelete && lstMStaff[i].objSObject.Id != null)
                     {
                        delete new MeetingStaff__c(Id=lstMStaff[i].objSObject.Id);
                        lstMStaff.remove(i);
                        break;
                     }
                    else if(lstMStaff[i].isDelete)
                     {
                        lstMStaff.remove(i);
                        break;
                     }
                }
            }
            //Delete Company Record
            else if(strDelete == 'Company')
            {
                isCompanyError = false;
                for(Integer i=0;i<lstMCompany.size();i++)
                {
                    if(lstMCompany[i].isDelete && lstMCompany[i].objSObject.Id != null)
                    {
                        delete new MeetingCompany__c(Id=lstMCompany[i].objSObject.Id);
                        lstMCompany.remove(i);
                        break;
                    }
                    else if(lstMCompany[i].isDelete)
                    {
                        lstMCompany.remove(i);
                        break;
                    }
                }
            }
            else if(strDelete == 'FollowUpTask')
            {
            	for(Integer i=0;i<lstFollowUpTask.size();i++)
                {
                    if(lstFollowUpTask[i].isDelete && lstFollowUpTask[i].objSObject.Id != null)
                    {
                        delete new Task(Id=lstFollowUpTask[i].objSObject.Id);
                        lstFollowUpTask.remove(i);
                        break;
                    }
                    else if(lstFollowUpTask[i].isDelete)
                    {
                        lstFollowUpTask.remove(i);
                        break;
                    }
                }
            }
    	}
    	catch(Exception e)
    	{
    		// do nothing
    	}

     }
    /* End - Delete Records */
}