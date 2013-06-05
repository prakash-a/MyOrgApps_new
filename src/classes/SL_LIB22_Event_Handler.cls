/**
 
* \author Rehan
 
* \date 13/Feb/2012
 
* \see http://silverline.jira.com/browse/SILVERLINE-35
 
* \brief SL_Event_Handler. Runs on AfterDelete. 
 
* \test SL_TestAllTriggers.cls 
 
*/
public with sharing class SL_LIB22_Event_Handler 
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public SL_LIB22_Event_Handler (boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /*  Function for OnAfterDelete  */
    public void OnAfterInsert(Map<Id, Event> mapEventOld)
    {
        try
        {
            List<Meeting_Log__c> lstMeetingLog = new List<Meeting_Log__c>(); // List for Storing all Meeting Log records which will be inserting through trigger.
            for(Event objEvent : mapEventOld.values())
            {
                // Checking all Event are Main Event and not child event inserted.
                if(objEvent.ParentTaskId__c == NULL)
                {
                    // Creating Meeting Log Record.
                    Meeting_Log__c objML = new Meeting_Log__c();
                    objML.ActivityID__c = objEvent.Id;
                    objML.Subject__c = objEvent.Subject;
                    objML.Description__c = objEvent.Description;
                    objML.Date__c = objEvent.ActivityDate; 
                    lstMeetingLog.add(objML);
                }
            }
            
            // Checking the List of Meeting Log Records and then inserting.
            if(lstMeetingLog.size() > 0)
            {
                insert lstMeetingLog;
                
                // Updating Event for All Meeting Log which are been inserted by them.
                List<Event> lstEvent = new List<Event>();
                for(Meeting_Log__c objML : lstMeetingLog)
                {
                    // Updating Event for each Meeting Log. 
                    Event objEvent = new Event(Id = objML.ActivityID__c);
                    objEvent.Related_Log_Id__c = objML.Id;
                    lstEvent.add(objEvent);
                }
                if(lstEvent.size() > 0)
                    update lstEvent;
            }   
        }
        catch(Exception e)
        {
            // do nothing.
        }
    }
        
    
    /*  Function for OnAfterDelete      */
    public void OnAfterDelete(Map<Id, Event> mapEventOld)
    {
        try
        {
            Set<Id> setMeetingLogIds = new Set<Id>();
            List<Meeting_Log__c> lstMeetingLog = new List<Meeting_Log__c>();// Taking list for storing List of Meeting Logs
            
            // fetching all MeetingLog ids from Event for deleting all MeetingLog records.
            for(Event objEvent : mapEventOld.values())
            {
                setMeetingLogIds.add(objEvent.Related_Log_Id__c);
            }
            
            // Storing all Meeting log in List for Delete purpose.
            for(Meeting_Log__c objMeeting : [Select Id from Meeting_Log__c where Id IN: setMeetingLogIds])
            {
                lstMeetingLog.add(objMeeting);
            }
            
            // Checking size and boolean variable from static Class for handling Recursive trigger(Event delete Meeting Log and Meeing Log delete Event).
            if(lstMeetingLog.size() > 0 && SL_LIB22_RecursionHelper.getisDelete() == true)
                delete lstMeetingLog;
        }
        catch(Exception e)
        {
            // do nothing.
        }
    }
}