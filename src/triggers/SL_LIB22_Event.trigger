/*Trigger on delete of Event object
* Trigger Name  : SL_Event 
* JIRA Ticket   : 
* Created on    : 
* Modified by   : SL
* Description   : Implement a trigger on Event to delete Meeting Log Records related to Event.Related_Log_Id field
*/
trigger SL_LIB22_Event on Event (after insert, after delete) 
{
    SL_LIB22_Event_Handler handler = new SL_LIB22_Event_Handler(Trigger.isExecuting, Trigger.size);
    
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