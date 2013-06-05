public with sharing class SL_LIB22_MeetingLog_Report
{
    public String strId {get;set;}
    public String strCheck {get;set;}
    public String strMeetingLogId {get;set;}
    public Event objEvent {get;set;}
    public Task objTask {get;set;}
    public Meeting_Log__c objMeetingLog {get;set;}
    public list<SL_LIB22_MeetingLog_GenericWrapper> lstMASObjectData {get;set;}
    public list<SL_LIB22_MeetingLog_GenericWrapper> lstMSSObjectData {get;set;}
    public list<SL_LIB22_MeetingLog_GenericWrapper> lstMCSObjectData {get;set;}
    public list<SL_LIB22_MeetingLog_GenericWrapper> lstFTSObjectData {get;set;}

    public SL_LIB22_MeetingLog_GenericWrapper objSLMeetingLogGenericWrapper {get;set;}

    public SL_LIB22_MeetingLog_Report()
    {
        initialise();

        strId = Apexpages.currentPage().getParameters().get('Id');
        strMeetingLogId = Apexpages.currentPage().getParameters().get('MLogId');

        fetchData();

        lstFTSObjectData = getDataForRelatedList('FollowUpTask');
    }

    public void initialise()
    {
        strId = strMeetingLogId = strCheck ='';
        objEvent = new Event();
        objTask = new Task();
        objMeetingLog = new Meeting_Log__c();
        lstMASObjectData = new list<SL_LIB22_MeetingLog_GenericWrapper>();
        lstMSSObjectData = new list<SL_LIB22_MeetingLog_GenericWrapper>();
        lstMCSObjectData = new list<SL_LIB22_MeetingLog_GenericWrapper>();
        lstFTSObjectData = new list<SL_LIB22_MeetingLog_GenericWrapper>();

        objSLMeetingLogGenericWrapper = new SL_LIB22_MeetingLog_GenericWrapper();

    }

    public void fetchData()
    {
        if(strId != NULL && strId != '')
        {
            strCheck = String.valueOf(Id.valueOf(strId).getSObjectType());
            if(strCheck == 'Task')
            {
                Map<String, Schema.SObjectField> M = Schema.SObjectType.Task.fields.getMap();
                String strFields = '';
                for(Schema.SObjectField s : M.values())
                {
                    strFields += String.valueOf(s)+',';
                }
                String taskFields = strFields.substring(0,strFields.length()-1);
                List<SObject> lstRecord = new List<SObject>();
                // Fetching the record from ORG Database
                lstRecord = Database.query(' Select ' + taskFields  + ' from Task where id=\'' + strId + '\'');
                objTask =  (lstRecord.size() > 0) ? (Task)lstRecord[0] : new Task();
            }
            else if(strCheck == 'Event')
            {
                Map<String, Schema.SObjectField> M = Schema.SObjectType.Event.fields.getMap();
                String strFields = '';
                for(Schema.SObjectField s : M.values())
                {
                    strFields += String.valueOf(s)+',';
                }
                String eventFields = strFields.substring(0,strFields.length()-1);
                List<SObject> lstRecord = new List<SObject>();
                lstRecord= Database.query(' Select ' + eventFields  + ' from Event where id=\'' + strId + '\'');
                objEvent =  (lstRecord.size() > 0) ? (Event)lstRecord[0] : new Event() ;
            }
        }
    }

    /* Start - Function Fill Related Lists*/
        public List<SL_LIB22_MeetingLog_GenericWrapper> getDataForRelatedList(String strRelatedListName)
        {
            try
            {
                List<SL_LIB22_MeetingLog_GenericWrapper> lstRelatedList = new List<SL_LIB22_MeetingLog_GenericWrapper>();
                if(strRelatedListName == 'FollowUpTask')
                {
                    Map<String, Schema.SObjectField> M = Schema.SObjectType.Task.fields.getMap();
                    String strFields = '';
                    for(Schema.SObjectField s : M.values())
                    {
                        strFields += String.valueOf(s)+',';
                    }
                    String taskFields = strFields.substring(0,strFields.length()-1);

                    if(strCheck == 'Task')
                    {
                        for(Task objFollowTask :Database.query(' Select ' + taskFields  + ' from Task where Meeting_Log__c = false AND ParentTaskId__c = ' +  '\'' + objTask.Id + '\'' + ' ORDER BY Subject Limit 1000'))
                        {
                            SL_LIB22_MeetingLog_GenericWrapper obj = new SL_LIB22_MeetingLog_GenericWrapper(objFollowTask);
                            lstRelatedList.add(obj);
                        }
                    }
                    else if(strCheck == 'Event')
                    {
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
                // do nothing
                return null;
            }
        }
    /* End - Function Fill Related Lists*/
}