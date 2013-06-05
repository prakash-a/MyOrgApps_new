/*Trigger on insert and delete of MeetingCompany__c
* Trigger Name  : SL_MeetingCompany
* JIRA Ticket   : 
* Created on    : 
* Modified by   : SL
* Description   : Implement a trigger on MeetingCompany__c to insert Child Task/Event for repective MeetingCompany__c record and same delete that Task/Event record
                   when MeetingCompany__c record is deleted
*/
trigger SL_LIB22_MeetingCompany on MeetingCompany__c (before insert, after insert, after delete)
{
    SL_LIB22_MeetingSObject_Handler handler = new SL_LIB22_MeetingSObject_Handler(Trigger.isExecuting, Trigger.size);

    if(trigger.IsInsert)
    {
        if(trigger.IsBefore)
        {
            handler.OnBeforeInsert(trigger.new, 'MeetingCompany__c', 'Company__c');
        }
        else
        {
            handler.OnAfterInsert(trigger.newMap, 'MeetingCompany__c', 'Company__c');
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