/**

* \author Rehan Dawt

* \Modified :03/Feb/2012

* \see :

* \brief : Displaying all the Related MeetingAttendee, MeetingStaff, MeetingCompany, FollowUpTask records related to one Task/Event(Meeting Log)

* \test : SL_TestAllClasses.cls

*/
public without sharing class SL_LIB22_MeetingLog_Detail
{
    /* Start - Global Variables */
        public Meeting_Log__c objMLog {get;set;}//Meeting Log Object

        public list<SL_MultiConnect__c> lstMultiConnect {get;set;}

        private String strId {get;set;}//To Identify Task Page
        public String strMeetingLogId {get;set;}//To Identify Task Page
        public String strDelete {get;set;}//To Delete Rows
        public String strTaskSub{get;set;}
        public Boolean isEdit{get;set;}
        public String strCheck {get;set;}

        public Task objTask{get;set;}
        public Event objEvent {get;set;}
        public Contact objCon{get;set;}

        public Boolean isErrorMessage {get;set;}

        //RelatedListRecord Lists
        public List<SL_LIB22_MeetingLog_GenericWrapper> lstMASObjectData {get;set;}
        public List<SL_LIB22_MeetingLog_GenericWrapper> lstMSSObjectData {get;set;}
        public List<SL_LIB22_MeetingLog_GenericWrapper> lstMCSObjectData {get;set;}
        public List<SL_LIB22_MeetingLog_GenericWrapper> lstFTSObjectData {get;set;}

        public String strMSobjectId {get;set;}

    /* End - Global Variables */

    /* Start - Constructor */

        public SL_LIB22_MeetingLog_Detail()
        {
            try
            {
                // Initialize all global variables.
                InitializeGlobalVariables();

                // Storing the value of Task Id from URL Parameter.
                strId = apexPages.currentPage().getParameters().get('Id');
                strCheck = apexPages.currentPage().getParameters().get('isWhat');

                //lstFollowTaskFeature = [Select Name, FollowUp_Task__c From SL_FollowUpTask__c where Name = 'FollowUp Task Feature' limit 1];

                lstMultiConnect = [Select Sent_an_Email__c, PDF_Report__c, Name, FollowUp_Task__c, Create_Tasks__c, Create_Events__c,
                                    CopyTask__c
                                    From SL_MultiConnect__c
                                    WHERE Name = 'Multi-Connect'
                                    LIMIT 1];


                if(strId != '' && strId != null )
                {
                    if(strCheck == 'Task')
                    {
                        Map<String, Schema.SObjectField> M = Schema.SObjectType.Task.fields.getMap();
                        String strFields = '';
                        for(Schema.SObjectField s : M.values())
                        {
                            strFields += String.valueOf(s)+',';
                        }
                        String TaskFields = strFields.substring(0,strFields.length()-1);
                        List<SObject> objRecord = new List<SObject>();
                        objRecord= Database.query(' Select ' + TaskFields  + ' from Task where id=\'' + strId + '\'');
                        objTask =  (objRecord.size() > 0) ? (Task)objRecord[0] : new Task();
                        if(objTask.WhoId!=null)
                        {
                             String strContact = String.valueOf(objTask.WhoId);

                            if(strContact.startsWith('003'))
                            {
                                objCon = [Select Phone,Email from Contact where Contact.Id =:strContact];
                            }

                        }
                    }
                    else if(strCheck == 'Event')
                    {
                        Map<String, Schema.SObjectField> M = Schema.SObjectType.Event.fields.getMap();
                        String strFields = '';
                        for(Schema.SObjectField s : M.values())
                        {
                            strFields += String.valueOf(s)+',';
                        }
                        String EventFields = strFields.substring(0,strFields.length()-1);
                        List<SObject> objRecord = new List<SObject>();
                        objRecord= Database.query(' Select ' + EventFields  + ' from Event where id=\'' + strId + '\'');
                        objEvent = (objRecord.size() > 0) ? (Event)objRecord[0] : new Event();
                        if(objEvent.WhoId!=null)
                        {
                             String strContact = String.valueOf(objEvent.WhoId);

                            if(strContact.startsWith('003'))
                            {
                                objCon = [Select Phone,Email from Contact where Contact.Id =:strContact];
                            }
                        }
                    }

                    String strContact = String.valueOf(objTask.WhoId);
                    strTaskSub = String.valueOf(objTask.Subject);
                    // Store the Meeting Log Id for an Task.
                    List<Meeting_Log__c> lstMeetingLog = [Select Id From Meeting_Log__c where ActivityID__c =: strId];

                    if(lstMeetingLog.size() > 0)
                        strMeetingLogId = lstMeetingLog[0].Id;

                    objMLog = (!lstMeetingLog.isEmpty()) ? lstMeetingLog[0] : null;
                    if(objMLog != null)
                    {
                        // Fill Attendee Related List
                        lstMASObjectData = SL_LIB22_MeetingLog_Utils.getSObjectDataForRelatedList('MeetingAttendee__c', objMLog.Id);

                        // Fill Staff Related List
                        lstMSSObjectData = SL_LIB22_MeetingLog_Utils.getSObjectDataForRelatedList('MeetingStaff__c', objMLog.Id);

                        // Fill Company Related List
                        lstMCSObjectData = SL_LIB22_MeetingLog_Utils.getSObjectDataForRelatedList('MeetingCompany__c', objMLog.Id);

                        if(lstMultiConnect.size() > 0 && lstMultiConnect[0].FollowUp_Task__c)
                        {
                            //Fill FollowUpTask Related List
                            lstFTSObjectData = getSObjectData('FollowUpTask');
                        }
                    }
                }
            }
            catch(Exception e)
            {
                // do nothing
                system.debug('???????????????Got an exception???????????????' + e.getMessage());
                SL_LIB22_MeetingLog_Utils.sendEmailOnException(e);

            }
        }
    /* End - Constructor */

    /* Start - Function Initialize variables */
        public void InitializeGlobalVariables()
        {
            objMLog = new Meeting_Log__c();

            lstMultiConnect = new List<SL_MultiConnect__c>();

            objTask = new Task();
            objEvent = new Event();
            objCon = new Contact();

            strCheck = '';
            strDelete = '';
            strId = '';
            strTaskSub = '';
            isEdit = false;
            isErrorMessage = false;
            strMeetingLogId = '';

            lstMASObjectData = new List<SL_LIB22_MeetingLog_GenericWrapper>();
            lstMSSObjectData = new List<SL_LIB22_MeetingLog_GenericWrapper>();
            lstMCSObjectData = new List<SL_LIB22_MeetingLog_GenericWrapper>();
            lstFTSObjectData = new List<SL_LIB22_MeetingLog_GenericWrapper>();

            strMSobjectId = '';
        }
    /* End - Function Initialize variables */

        public List<SL_LIB22_MeetingLog_GenericWrapper> getSObjectData(String strRelatedListName)
        {
            try
            {
                List<SL_LIB22_MeetingLog_GenericWrapper> lstRelatedList = new List<SL_LIB22_MeetingLog_GenericWrapper>();
                if(strRelatedListName == 'FollowUpTask')
                {
                	system.debug('???????????$$$$$$$$$$$$In$$$$$$$$$$??????????????' + strCheck);
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

    /* Start - Edit Redirect */
        public pageReference editRedirect()
        {
            try
            {
                String pageRefParam = '';
                if(objTask.Id != NULL)
                {
                    List<Task> lstTempTask = new List<Task>();
                    lstTempTask = [Select Id from Task where Id =: objTask.Id];
                    if(lstTempTask.size() > 0)
                    {
                        isEdit = true;
                        if(strCheck == 'Task')
                            pageRefParam = '/apex/SL_LIB22_MeetingLog_New?id='+ lstTempTask[0].Id+'&isWhat=Task';

                        PageReference objPageRef = new PageReference(pageRefParam);
                        objPageRef.setRedirect(true);
                        return objPageRef;
                    }
                    else
                    {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Record is already deleted.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }
                else if(objEvent.Id != NULL)
                {
                    List<Event> lstTempEvent = new List<Event>();
                    lstTempEvent = [Select Id from Event where Id =: objEvent.Id];

                    if(lstTempEvent.size() > 0)
                    {
                        isEdit = true;
                        if(strCheck == 'Event')
                            pageRefParam = '/apex/SL_LIB22_MeetingLog_New?id='+ lstTempEvent[0].Id+'&isWhat=Event';

                        PageReference objPageRef = new PageReference(pageRefParam);
                        objPageRef.setRedirect(true);
                        return objPageRef;
                    }
                    else
                    {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Record is already deleted.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }
                else
                {
                    isErrorMessage = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Record is already deleted.');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            }
            catch(Exception e)
            {
                // do nothing
                return null;
            }
        }

    /* End - edit Redirect */

    /* Start - Function Delete current record */
        public void deleteRecord()
        {
            try
            {
                if(strDelete == 'FollowUpTask')
                {
                    for(Integer i=0;i<lstFTSObjectData.size();i++)
                    {
                        if(lstFTSObjectData[i].isDelete && lstFTSObjectData[i].objSObject.Id != null)
                        {
                            delete new Task(Id=lstFTSObjectData[i].objSObject.Id);
                            lstFTSObjectData.remove(i);
                        }
                    }
                }
            }
            catch(Exception e)
            {
                // do nothing
            }
         }
    /* End - Function Delete current record */

    public Pagereference generatePDFReport()
    {
        Pagereference pr = new Pagereference('/apex/SL_LIB22_Meetinglog_Report?Id=' + strId + '&MLogId=' + strMeetingLogId);
        pr.setRedirect(true);
        return pr;
    }

    public Pagereference redirectSendEmail()
    {
        Pagereference pr = new Pagereference('/apex/SL_LIB22_Meetinglog_SendEmail?Id=' + strId + '&MLogId=' + strMeetingLogId);
        pr.setRedirect(true);
        return pr;
    }

}