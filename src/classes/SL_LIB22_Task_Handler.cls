/**
 
* \author Rehan
 
* \date 13/Feb/2012
 
* \see http://silverline.jira.com/browse/SILVERLINE-35
 
* \brief SL_Task_Handler. Runs on AfterDelete. 
 
* \test SL_TestAllTriggers.cls 
 
*/
public with sharing class SL_LIB22_Task_Handler 
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    /*  Constructor     */
    public SL_LIB22_Task_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /*  Function for OnAfterInsert      */
    public void OnAfterInsert(Map<Id, Task> mapTaskOld)
    {
        try
        {
            List<Meeting_Log__c> lstMeetingLog = new List<Meeting_Log__c>(); // List for Storing Meeting Log which will be inserted for Each Task Record.
            for(Task objTask : mapTaskOld.values())
            {
                // Checking Task which is not a child Task and it is Main Task which is been inserted.
                if(objTask.ParentTaskId__c == NULL)
                {
                    // Creating a Meeting Log Record.
                    Meeting_Log__c objML = new Meeting_Log__c();
                    objML.ActivityID__c = objTask.Id;
                    objML.Subject__c = objTask.Subject;
                    objML.Description__c = objTask.Description;
                    objML.Date__c = objTask.ActivityDate; 
                    lstMeetingLog.add(objML);
                }
            }
            
            // Checking the size of List of Meeting Log for inserting.
            if(lstMeetingLog.size() > 0)
            {
                insert lstMeetingLog;
                
                List<Task> lstTask = new List<Task>(); // List of Task which are updated for Each meeting Log Record whose id will be assign to their repective Task
                for(Meeting_Log__c objML : lstMeetingLog)
                {
                    // Updating the Task records with Meeting Log Id to it.
                    Task objTask = new Task(Id = objML.ActivityID__c);
                    objTask.Related_Log_Id__c = objML.Id;
                    objTask.ParentTaskId__c = objTask.Id;
                    lstTask.add(objTask);
                }
                
                // Checking the size of List of Task and then inserting.
                if(lstTask.size() > 0)
                    update lstTask;
            }   
        }
        catch(Exception e)
        {
            // do nothing.
        }
    }
    
    /*  Function for OnAfterDelete      */
    public void OnAfterDelete(Map<Id, Task> mapTaskOld)
    {
        try
        {
            List<Meeting_Log__c> lstMeetingLog = new List<Meeting_Log__c>(); // Taking list for storing List of Meeting Logs
            List<Task> lstTask = new List<Task>(); // List for Storing Ids of All Task that have Follow up Task.
            Set<Id> setMeetingLog = new Set<Id>();
            
            // fetching all MeetingLog ids from Task for deleting all those records.
            for(Task objTask : mapTaskOld.values()) 
            {
                setMeetingLog.add(objTask.Related_Log_Id__c);
            }
            
            // Storing all Meeting log in List for Delete purpose.
            for(Meeting_Log__c objMeeting : [Select Id from Meeting_Log__c where Id IN: setMeetingLog])
            {
                lstMeetingLog.add(objMeeting);
            }
            
            //Querying Task to find related followup Task and delete it.
            for(Task objFollowTask : [Select Id from Task where ParentTaskId__c IN: mapTaskOld.keySet()])
            {
                lstTask.add(objFollowTask);
            }
            
            // Checking size of List of Task records and Deleting all Follow Up Task.
            if(lstTask.size() > 0)
                delete lstTask;  
            
            // Checking size and boolean variable from static Class for handling Recursive trigger(Task delete Meeting Log and Meeing Log delete Task).
            if(lstMeetingLog.size() > 0 && SL_LIB22_RecursionHelper.getisDelete() == true)
                delete lstMeetingLog;   
        
        }
        catch(Exception e)
        {
            // do nothing;
        }
    }
}