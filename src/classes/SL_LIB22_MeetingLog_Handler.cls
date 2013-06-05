/**
 
* \author Rehan
 
* \date 13/Feb/2012
 
* \see http://silverline.jira.com/browse/SILVERLINE-35
 
* \brief SL_MeetingLog_Handler. Runs on BeforeDelete. 
 
* \test SL_TestAllTriggers.cls
 
*/
public with sharing class SL_LIB22_MeetingLog_Handler 
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public SL_LIB22_MeetingLog_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /*  Function for onBeforeInsert     */
    public void onBeforeDelete(Map<Id, Meeting_Log__c> mapMLogOld)
    {
        try
        {
            Set<Id> setAllMeetingLogChildIds = new Set<Id>(); // Set to store all MeetingLogChilds Records Ids
            List<Task> lstTask = new List<Task>(); // List for Storing all Parent Task.
            List<Task> lstTaskChilds = new List<Task>(); // List for Storing all Task related to MeetingLog Childs record 
            List<Event> lstEvent = new List<Event>(); // List for Storing all Parent Event.
            List<Event> lstEventChilds = new List<Event>(); // List for Storing all Event related to MeetingLog Childs record
            
            // Fetching all Task records related to MeetingLogs
            for(Task objTask : [Select Id from Task where Related_Log_Id__c IN: mapMLogOld.keySet()])
            {
                lstTask.add(objTask);
            }
            
            // Fetching all Event records related to MeetingLogs
            for(Event objEvent : [Select Id from Event where Related_Log_Id__c IN: mapMLogOld.keySet()])
            {
                lstEvent.add(objEvent);
            }
            
            // Deleting the Meeting Attendee Records
            for(MeetingAttendee__c objMA : [Select Id from MeetingAttendee__c where Meeting_Log__c IN: mapMLogOld.keySet()])
            {
                setAllMeetingLogChildIds.add(objMA.Id);
            }
            
            // Deleting the Meeting Staff Records
            for(MeetingStaff__c objMS : [Select Id from MeetingStaff__c where Meeting_Log__c IN: mapMLogOld.keySet()])
            {
                setAllMeetingLogChildIds.add(objMS.Id);
            }
            
            // Deleting the Meeting Company Records
            for(MeetingCompany__c objMC : [Select Id from MeetingCompany__c where Meeting_Log__c IN: mapMLogOld.keySet()])
            {
                setAllMeetingLogChildIds.add(objMC.Id);
            }
            
            for(Task objTask : [Select Id from Task where Related_Log_Id__c IN: setAllMeetingLogChildIds])
            {
                lstTaskChilds.add(objTask);
            }
            
            for(Event objEvent : [Select Id from Event where Related_Log_Id__c IN: setAllMeetingLogChildIds])
            {
                lstEventChilds.add(objEvent);   
            }
            
            if(lstTaskChilds.size() > 0)
                delete lstTaskChilds;
            
            if(lstEventChilds.size() > 0)
                delete lstEventChilds;
            
            // Keeping this Seperate List as it consits of Meeting Log Task Id and if it is called first then Trigger on Task will be called.
            if(lstTask.size() > 0)
            {
                SL_LIB22_RecursionHelper.setisDelete(false);
                delete lstTask;
            }
            // Keeping this Seperate List as it consits of Meeting Log Event Id and if it is called first then Trigger on Event will be called.
            if(lstEvent.size() > 0)
                delete lstEvent;
                
                    
        }
        catch(Exception e)
        {
            // do nothing
        }
    }
}