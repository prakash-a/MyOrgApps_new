/*Trigger on insert and delete of MeetingStaff__c
* Trigger Name  : SL_MeetingStaff
* JIRA Ticket   :
* Created on    :
* Modified by   : SL
* Description   : Implement a trigger on MeetingStaff__c to insert Child Task/Event for repective MeetingStaff__c record and same delete that Task/Event record
                   when MeetingStaff__c record is deleted
*/
trigger SL_LIB22_MeetingStaff on MeetingStaff__c (before insert, after insert, after delete)
{
    SL_LIB22_MeetingSObject_Handler handler = new SL_LIB22_MeetingSObject_Handler(Trigger.isExecuting, Trigger.size);

    if(trigger.IsInsert)
    {
        if(trigger.IsBefore)
        {
            handler.OnBeforeInsert(trigger.new, 'MeetingStaff__c', 'Contact__c');
        }
        else
        {
            handler.OnAfterInsert(trigger.newMap, 'MeetingStaff__c', 'Contact__c');
        }
    }
    else if(trigger.isDelete)
    {
        if(trigger.isBefore)
        {

        }
        else
        {
            handler.OnAfterDelete(trigger.oldMap);
        }
    }
}