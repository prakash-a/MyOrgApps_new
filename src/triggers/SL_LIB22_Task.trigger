/*Trigger on delete of Task
* Trigger Name  : SL_Task 
* JIRA Ticket   : 
* Created on    : 
* Modified by   : SL
* Description   : Implement a trigger on Task to delete that MeetingLog record, when Task record is deleted  
*/
trigger SL_LIB22_Task on Task (after insert, after delete) 
{
    SL_LIB22_Task_Handler handler = new SL_LIB22_Task_Handler(Trigger.isExecuting, Trigger.size);
    
    if(trigger.isInsert)
    {
        if(trigger.isAfter)
        {
            handler.OnAfterInsert(trigger.newMap);
        }
    }
    else if(trigger.isDelete) 
    {
        if(trigger.isAfter) 
        {
            handler.onAfterDelete(trigger.oldMap);
        }
    }
}