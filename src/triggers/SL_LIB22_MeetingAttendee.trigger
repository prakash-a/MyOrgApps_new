/*Trigger on insert and delete of MeetingAttendee__c
* Trigger Name  : SL_MeetingAttendee
* JIRA Ticket   : GUGG-4
* Created on    : 03/Feb/2012
* Modified by   : SL
* Description   : Implement a trigger on MeetingAttendee__c to insert Child Task/Event for repective MeetingAttendee__c record and same delete that Task/Event record
                   when MeetingAttendee__c record is deleted
*/
trigger SL_LIB22_MeetingAttendee on MeetingAttendee__c (before insert, after insert, after delete)
{
    SL_LIB22_MeetingSObject_Handler handler = new SL_LIB22_MeetingSObject_Handler(Trigger.isExecuting, Trigger.size);

    if(trigger.IsInsert)
    {
        if(trigger.IsBefore)
        {
            handler.OnBeforeInsert(trigger.new, 'MeetingAttendee__c', 'Attendee__c');
        }
        else
        {
            handler.OnAfterInsert(trigger.newMap, 'MeetingAttendee__c', 'Attendee__c');
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