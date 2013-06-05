/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_LIB22_TestAllTriggers 
{

    static testMethod void SL_Task() 
    {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        Task objTask = new Task();
        objTask.WhoId = objContact.Id;
        objTask.Subject = 'Test Subject';
        insert objTask;
        
        Meeting_Log__c objML = new Meeting_Log__c();
        objML.ActivityID__c = objTask.Id;
        objML.Subject__c = 'Test Meeting_Log__c';
        objML.Date__c = date.today();
        insert objML;
        
        objTask.Related_Log_Id__c = objML.Id;
        update objTask;
        
        delete objTask; 
        
    }
    
    static testMethod void SL_Event() 
    {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        Event objEvent = new Event();
        objEvent.Subject = 'Test Subject';
        objEvent.WhoId = objContact.Id;
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now();
        insert objEvent;
        
        Meeting_Log__c objML = new Meeting_Log__c();
        objML.ActivityID__c = objEvent.Id;
        objML.Subject__c = 'Test Meeting_Log__c';
        objML.Date__c = date.today();
        insert objML;
        
        objEvent.Related_Log_Id__c = objML.Id;
        update objEvent;
        
        delete objEvent;
                
    }
    
    static testMethod void SL_MeetingLog() 
    {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        Event objEvent = new Event();
        objEvent.Subject = 'Test Subject';
        objEvent.WhoId = objContact.Id;
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now();
        insert objEvent;
        
        Task objTask = new Task();
        objTask.WhoId = objContact.Id;
        objTask.Subject = 'Test Subject';
        insert objTask;
        
        Meeting_Log__c objML = new Meeting_Log__c();
        objML.ActivityID__c = objTask.Id;
        objML.Subject__c = 'Test Meeting_Log__c';
        objML.Date__c = date.today();
        insert objML;
        
        Meeting_Log__c objML1 = new Meeting_Log__c();
        objML1.ActivityID__c = objEvent.Id;
        objML1.Subject__c = 'Test Meeting_Log__c';
        objML1.Date__c = date.today();
        insert objML1;
        
        objTask.Related_Log_Id__c = objML.Id;
        update objTask;
        
        objEvent.Related_Log_Id__c = objML1.Id;
        update objEvent;
        
        MeetingAttendee__c objMA = new MeetingAttendee__c();
        objMA.Meeting_Log__c = objML.Id;
        objMA.Attendee__c = objContact.Id;
        insert objMA;
        
        MeetingStaff__c objMS = new MeetingStaff__c();
        objMS.Meeting_Log__c = objML.Id;
        objMS.Contact__c = objContact.Id;
        insert objMS;
        
        MeetingCompany__c objMC = new MeetingCompany__c();
        objMC.Company__c = objAccount.Id;
        objMC.Meeting_Log__c = objML1.Id;
        insert objMC;
        
        delete objML;
        delete objML1;        
        
    }
    
    static testMethod void SL_MeetingAttendee() 
    {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        Task objTask = new Task();
        objTask.WhoId = objContact.Id;
        objTask.Subject = 'Test Subject';
        insert objTask;
        
        Event objEvent = new Event();
        objEvent.Subject = 'Test Subject';
        objEvent.WhoId = objContact.Id;
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now();
        insert objEvent;
        
        Meeting_Log__c objML = new Meeting_Log__c();
        objML.ActivityID__c = objTask.Id;
        objML.Subject__c = 'Test Meeting_Log__c';
        objML.Date__c = date.today();
        insert objML;
        
        Meeting_Log__c objML1 = new Meeting_Log__c();
        objML1.ActivityID__c = objEvent.Id;
        objML1.Subject__c = 'Test Meeting_Log__c';
        objML1.Date__c = date.today();
        insert objML1;
        
        MeetingAttendee__c objMA = new MeetingAttendee__c();
        objMA.Meeting_Log__c = objML.Id;
        objMA.Attendee__c = objContact.Id;
        insert objMA;
        
        MeetingAttendee__c objMA1 = new MeetingAttendee__c();
        objMA1.Meeting_Log__c = objML1.Id;
        objMA1.Attendee__c = objContact.Id;
        insert objMA1;
        
        objTask.Related_Log_Id__c = objMA.Id;
        update objTask;
        
        objEvent.Related_Log_Id__c = objMA1.Id;
        update objEvent;    
        
        delete objMA;
        delete objMA1;        
    }
    
    static testMethod void SL_MeetingStaff() 
    {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        Task objTask = new Task();
        objTask.WhoId = objContact.Id;
        objTask.Subject = 'Test Subject';
        insert objTask;
        
        Event objEvent = new Event();
        objEvent.Subject = 'Test Subject';
        objEvent.WhoId = objContact.Id;
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now();
        insert objEvent;
        
        Meeting_Log__c objML = new Meeting_Log__c();
        objML.ActivityID__c = objTask.Id;
        objML.Subject__c = 'Test Meeting_Log__c';
        objML.Date__c = date.today();
        insert objML;
        
        Meeting_Log__c objML1 = new Meeting_Log__c();
        objML1.ActivityID__c = objEvent.Id;
        objML1.Subject__c = 'Test Meeting_Log__c';
        objML1.Date__c = date.today();
        insert objML1;
        
        MeetingStaff__c objMS = new MeetingStaff__c();
        objMS.Meeting_Log__c = objML.Id;
        objMS.Contact__c = objContact.Id;
        insert objMS;
        
        MeetingStaff__c objMS1 = new MeetingStaff__c();
        objMS1.Meeting_Log__c = objML1.Id;
        objMS1.Contact__c = objContact.Id;
        insert objMS1;
        
        objTask.Related_Log_Id__c = objMS.Id;
        update objTask;
        
        objEvent.Related_Log_Id__c = objMS1.Id;
        update objEvent;    
        
        delete objMS;
        delete objMS1;
    }
    
    static testMethod void SL_MeetingCompany() 
    {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        Account objAccount1 = new Account();
        objAccount1.Name = 'Test Account1';
        insert objAccount1;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        Task objTask = new Task();
        objTask.WhoId = objContact.Id;
        objTask.Subject = 'Test Subject';
        insert objTask;
        
        Event objEvent = new Event();
        objEvent.Subject = 'Test Subject';
        objEvent.WhoId = objContact.Id;
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now();
        insert objEvent;
        
        Meeting_Log__c objML = new Meeting_Log__c();
        objML.ActivityID__c = objTask.Id;
        objML.Subject__c = 'Test Meeting_Log__c';
        objML.Date__c = date.today();
        insert objML;
        
        Meeting_Log__c objML1 = new Meeting_Log__c();
        objML1.ActivityID__c = objEvent.Id;
        objML1.Subject__c = 'Test Meeting_Log__c';
        objML1.Date__c = date.today();
        insert objML1;
        
        MeetingCompany__c objMC = new MeetingCompany__c();
        objMC.Meeting_Log__c = objML.Id;
        objMC.Company__c = objAccount.Id;
        insert objMC;
        
        MeetingCompany__c objMC1 = new MeetingCompany__c();
        objMC1.Meeting_Log__c = objML.Id;
        objMC1.Company__c = objAccount1.Id;
        insert objMC1;
        
        objTask.Related_Log_Id__c = objMC.Id;
        update objTask;
        
        objEvent.Related_Log_Id__c = objMC1.Id;
        update objEvent;    
        
        delete objMC;
        delete objMC1;
        
    }
    
    
}