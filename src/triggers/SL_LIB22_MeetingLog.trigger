/*Trigger on delete of Meeting_Log__c
* Trigger Name  : SL_MeetingLog 
* JIRA Ticket   : 
* Created on    : 
* Modified by   : SL
* Description   : Implement a trigger on Meeting_Log__c to delete that Task/Event record, when Meeting_Log__c record is deleted  
*/
trigger SL_LIB22_MeetingLog on Meeting_Log__c (before delete) 
{
    SL_LIB22_MeetingLog_Handler handler = new SL_LIB22_MeetingLog_Handler(Trigger.isExecuting, Trigger.size);
    
    if(trigger.isDelete)
    {
        if(trigger.isBefore)
        {
            handler.onBeforeDelete(trigger.oldMap);
        }
    }
}