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
private class SL_LIB22_TestAllClasses
{
	static Event objEvent;
    static Task objTask;
    static Task objChildTaskForTask;
    static Task objChildTaskForEvent;
    static Account objTestAccount;
    static Contact objTestContactEmployee;
    static Contact objTestContactNonEmployee;
    static Meeting_Log__c objTestMeetingLog;
    static MeetingAttendee__c objTestMeetingAttendee;
    static MeetingStaff__c objTestMeetingStaff;
    static MeetingCompany__c objTestMeetingCompany;
    static SL_MultiConnect__c objMultiConnect;

    static void createTestRecords()
    {
        objMultiConnect = new SL_MultiConnect__c();
        objMultiConnect.CopyTask__c = true;
        objMultiConnect.Create_Events__c = true;
        objMultiConnect.Create_Tasks__c = true;
        objMultiConnect.Custom_Lookup_Related_To__c = true;
        objMultiConnect.FollowUp_Task__c = true;
        objMultiConnect.Name = 'Multi-Connect';
        objMultiConnect.Sent_an_Email__c = true;
        objMultiConnect.PDF_Report__c = true;
        insert objMultiConnect;

        objTestAccount = new Account();
        objTestAccount.Name = 'Test Account';
        insert objTestAccount;

        objTestContactEmployee = new Contact();
        objTestContactEmployee.LastName = 'Contact Employee 1';
        objTestContactEmployee.AccountId = objTestAccount.Id;
        insert objTestContactEmployee;

        objTestContactNonEmployee = new Contact();
        objTestContactNonEmployee.LastName = 'Contact Non Employee 1';
        objTestContactNonEmployee.AccountId = objTestAccount.Id;
        insert objTestContactNonEmployee;

        objEvent = new Event();
        objEvent.Subject = 'Test Event Record 1';
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now() + 1;
        objEvent.WhatId = objTestAccount.Id;
        objEvent.WhoId = objTestContactEmployee.Id;
        insert objEvent;

        objTask = new Task();
        objTask.Subject = 'Test Event Record 1';
        objTask.Status = 'Closed';
        objTask.ActivityDate = Date.today();
        objTask.WhatId = objTestAccount.Id;
        objTask.WhoId = objTestContactEmployee.Id;
        insert objTask;

        objChildTaskForTask = new Task();
        objChildTaskForTask.Subject = 'Test Task Record 1';
        objChildTaskForTask.Status = 'Closed';
        objChildTaskForTask.ActivityDate = Date.today();
        objChildTaskForTask.WhatId = objTestAccount.Id;
        objChildTaskForTask.WhoId = objTestContactEmployee.Id;
        objChildTaskForTask.ParentTaskId__c = objTask.Id;
        objChildTaskForTask.Meeting_Log__c = false;
        insert objChildTaskForTask;

        objChildTaskForEvent = new Task();
        objChildTaskForEvent.Subject = 'Test Event Record 1';
        objChildTaskForTask.Status = 'Closed';
        objChildTaskForTask.ActivityDate = Date.today();
        objChildTaskForTask.WhatId = objTestAccount.Id;
        objChildTaskForTask.WhoId = objTestContactEmployee.Id;
        objChildTaskForEvent.Meeting_Log__c = false;
        objChildTaskForEvent.ParentTaskId__c = objEvent.Id;
        insert objChildTaskForEvent;

        objTestMeetingLog = new Meeting_Log__c();
        objTestMeetingLog = [Select Id, ActivityID__c From Meeting_Log__c where ActivityID__c =: objEvent.Id];

        objTestMeetingAttendee = new MeetingAttendee__c();
        objTestMeetingAttendee.Attendee__c = objTestContactNonEmployee.id;
        objTestMeetingAttendee.Notes__c = 'Test Attendee Notes 1';
        objTestMeetingAttendee.Meeting_Log__c = objTestMeetingLog.Id;
        insert objTestMeetingAttendee;

        objTestMeetingStaff = new MeetingStaff__c();
        objTestMeetingStaff.Contact__c = objTestContactEmployee.Id;
        objTestMeetingStaff.Notes__c = 'Test Staff Notes 1';
        objTestMeetingStaff.Meeting_Log__c = objTestMeetingLog.Id;
        insert objTestMeetingStaff;

        objTestMeetingCompany = new MeetingCompany__c();
        objTestMeetingCompany.Company__c = objTestAccount.Id;
        objTestMeetingCompany.Notes__c = 'Test company Notes 1';
        objTestMeetingCompany.Meeting_Log__c = objTestMeetingLog.Id;
        insert objTestMeetingCompany;

    }

    // For Event Detail Page
    static testMethod void SL_LIB22_MeetingLog_Report_Event()
    {
        createTestRecords();

        apexpages.currentPage().getParameters().put('Id',objEvent.Id);
        apexpages.currentPage().getParameters().put('MLogId',objTestMeetingLog.Id);

        SL_LIB22_MeetingLog_Report objMLClass = new SL_LIB22_MeetingLog_Report();
    }

    // For Event Detail Page
    static testMethod void SL_LIB22_MeetingLog_Report_Task()
    {
        createTestRecords();

        apexpages.currentPage().getParameters().put('Id',objTask.Id);
        apexpages.currentPage().getParameters().put('MLogId',objTestMeetingLog.Id);

        SL_LIB22_MeetingLog_Report objMLClass = new SL_LIB22_MeetingLog_Report();
    }

    // For Event Detail Page
    static testMethod void SL_LIB22_MeetingLog_Detail_Event()
    {
        createTestRecords();

        apexpages.currentPage().getParameters().put('id',objEvent.Id);
        apexpages.currentPage().getParameters().put('isWhat','Event');

        SL_LIB22_MeetingLog_Detail objMLClass = new SL_LIB22_MeetingLog_Detail();
        system.debug('?????????objMLClass???????????' + objMLClass);
        objMLClass.editRedirect();

        objMLClass.lstMASObjectData[0].isDelete = true;
        objMLClass.strDelete = 'Attendee';
        objMLClass.deleteRecord();

        objMLClass.lstMSSObjectData[0].isDelete = true;
        objMLClass.strDelete = 'Staff';
        objMLClass.deleteRecord();

        objMLClass.lstMCSObjectData[0].isDelete = true;
        objMLClass.strDelete = 'Company';
        objMLClass.deleteRecord();

		objMLClass.lstFTSObjectData[0].isDelete = true;
        objMLClass.strDelete = 'FollowUpTask';
        objMLClass.deleteRecord();

        objMLClass.generatePDFReport();
        objMLClass.redirectSendEmail();

    }

    // For Task Detail Page
    static testMethod void SL_LIB22_MeetingLog_Detail_Task()
    {
        createTestRecords();

        apexpages.currentPage().getParameters().put('id',objTask.Id);
        apexpages.currentPage().getParameters().put('isWhat','Task');

        SL_LIB22_MeetingLog_Detail objMLClass = new SL_LIB22_MeetingLog_Detail();
        objMLClass.editRedirect();
    }


    // For Task
    static testMethod void SL_LIB22_MeetingLog_Redirect_Task()
    {

        objTestAccount = new Account();
        objTestAccount.Name = 'Test Account';
        insert objTestAccount;

        objTestContactEmployee = new Contact();
        objTestContactEmployee.LastName = 'Contact Employee 1';
        objTestContactEmployee.AccountId = objTestAccount.Id;
        insert objTestContactEmployee;

        Task objTestTask = new Task();
        objTestTask.OwnerId = Userinfo.getUserId();
        objTestTask.Subject = 'Call';
        objTestTask.WhatId = objTestAccount.Id;
        objTestTask.WhoId = objTestContactEmployee.Id;
        objTestTask.Description = 'Test';
        insert objTestTask;

        Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(objTestTask);

        apexpages.currentPage().getParameters().put('id',objTestTask.Id);
        apexpages.currentPage().getParameters().put('isWhat','Task');
        apexpages.currentPage().getParameters().put('retURL','/'+objTestAccount.Id);
        SL_LIB22_MeetingLog_Redirect objMClass = new SL_LIB22_MeetingLog_Redirect(std);

        objMClass.RedirectTaskEdit();
        objMClass.RedirectTaskDetail();

        objTestTask.Meeting_Log__c = true;
        update objTestTask;

        apexpages.currentPage().getParameters().put('id',objTestTask.Id);
        apexpages.currentPage().getParameters().put('isWhat','Task');
        apexpages.currentPage().getParameters().put('retURL','/'+objTestAccount.Id);
        SL_LIB22_MeetingLog_Redirect objMClass1 = new SL_LIB22_MeetingLog_Redirect(std);

        objMClass1.RedirectTaskEdit();
        objMClass1.RedirectTaskDetail();
    }

    // For Event
    static testMethod void SL_LIB22_MeetingLog_Redirect_Event()
    {

        objTestAccount = new Account();
        objTestAccount.Name = 'Test Account';
        insert objTestAccount;

        objTestContactEmployee = new Contact();
        objTestContactEmployee.LastName = 'Contact Employee 1';
        objTestContactEmployee.AccountId = objTestAccount.Id;
        insert objTestContactEmployee;

        objEvent = new Event();
        objEvent.OwnerId = Userinfo.getUserId();
        objEvent.Subject = 'Call';
        objEvent.WhatId = objTestAccount.Id;
        objEvent.WhoId = objTestContactEmployee.Id;
        objEvent.Description = 'Test';
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now();
        insert objEvent;

        Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(objEvent);

        apexpages.currentPage().getParameters().put('id',objEvent.Id);
        apexpages.currentPage().getParameters().put('isWhat','Event');
        apexpages.currentPage().getParameters().put('retURL','/'+objTestAccount.Id);
        SL_LIB22_MeetingLog_Redirect objMClass = new SL_LIB22_MeetingLog_Redirect(std);

        objMClass.RedirectEventEdit();
        objMClass.RedirectEventDetail();

        objEvent.Meeting_Log__c = true;
        update objEvent;

        apexpages.currentPage().getParameters().put('id',objEvent.Id);
        apexpages.currentPage().getParameters().put('isWhat','Event');
        apexpages.currentPage().getParameters().put('retURL','/'+objTestAccount.Id);
        SL_LIB22_MeetingLog_Redirect objMClass1 = new SL_LIB22_MeetingLog_Redirect(std);

        objMClass1.RedirectEventEdit();
        objMClass1.RedirectEventDetail();
    }

    static testMethod void SL_LIB22_MeetingLog_New_Event_NewRecordCase()
    {
        createTestRecords();

        apexpages.currentPage().getParameters().put('id',null);
        apexpages.currentPage().getParameters().put('isWhat','Event');
        apexpages.currentPage().getParameters().put('retURL','/'+objTestAccount.Id);

        SL_LIB22_MeetingLog_New objMLClass = new SL_LIB22_MeetingLog_New();
        objMLClass.objEvent.Subject = objEvent.Subject;
        objMLClass.objEvent.WhatId = objEvent.WhatId;
        objMLClass.objEvent.Description = objEvent.Description;
        objMLClass.objEvent.StartDateTime = objEvent.StartDateTime;
        objMLClass.objEvent.EndDateTime = objEvent.EndDateTime;

        objMLClass.strAddRow = 'Attendee';
        objMLClass.addRow();
        objMLClass.lstMAttendee[0].objSObject.put('Attendee__c' , objTestContactNonEmployee.Id);

        objMLClass.strAddRow = 'Staff';
        objMLClass.addRow();
        objMLClass.lstMStaff[0].objSObject.put('Contact__c' , objTestContactEmployee.Id);

        objMLClass.strAddRow = 'Company';
        objMLClass.addRow();
        objMLClass.lstMCompany[0].objSObject.put('Company__c' , objTestAccount.Id);

        objMLClass.strAddRow = 'FollowUpTask';
        objMLClass.addRow();

        objMLClass.SaveRedirect();
    }

    static testMethod void SL_LIB22_MeetingLog_New_Event_EditRecordCase()
    {
        createTestRecords();

        apexpages.currentPage().getParameters().put('id',objEvent.Id);
        apexpages.currentPage().getParameters().put('isWhat','Event');
        apexpages.currentPage().getParameters().put('retURL','/'+objTestAccount.Id);

        SL_LIB22_MeetingLog_New objMLClass = new SL_LIB22_MeetingLog_New();

        objMLClass.lstMAttendee[0].objSObject.put('Notes__c' ,'Test Note Attendee 1');
        objMLClass.lstMStaff[0].objSObject.put('Notes__c' , 'Test Note Staff 1');
        objMLClass.lstMCompany[0].objSObject.put('Notes__c' , 'Test Note Company 1');
        objMLClass.lstFollowUpTask[0].objSObject.put('Subject' , 'Test Subject 1');

        objMLClass.SaveRedirect();


    }

    static testMethod void SL_LIB22_MeetingLog_New_Event_DeleteRecordCase()
    {
        createTestRecords();

        apexpages.currentPage().getParameters().put('id',objEvent.Id);
        apexpages.currentPage().getParameters().put('isWhat','Event');
        apexpages.currentPage().getParameters().put('retURL','/'+objTestAccount.Id);

        SL_LIB22_MeetingLog_New objMLClass = new SL_LIB22_MeetingLog_New();

        objMLClass.strAddRow = 'Attendee';
        objMLClass.addRow();
        objMLClass.lstMAttendee[1].objSObject.put('Attendee__c' , objTestContactNonEmployee.Id);

        objMLClass.strAddRow = 'Staff';
        objMLClass.addRow();
        objMLClass.lstMStaff[1].objSObject.put('Contact__c' , objTestContactEmployee.Id);

        objMLClass.strAddRow = 'Company';
        objMLClass.addRow();
        objMLClass.lstMCompany[1].objSObject.put('Company__c' , objTestAccount.Id);

        // Id != NULL
        objMLClass.strDelete = 'Attendee';
        objMLClass.lstMAttendee[0].isDelete  = true;
        objMLClass.deleteRecord();

        objMLClass.strDelete = 'Staff';
        objMLClass.lstMStaff[0].isDelete  = true;
        objMLClass.deleteRecord();

        objMLClass.strDelete = 'Company';
        objMLClass.lstMCompany[0].isDelete  = true;
        objMLClass.deleteRecord();

        // Id == NULL
        objMLClass.strDelete = 'Attendee';
        objMLClass.lstMAttendee[0].isDelete  = true;
        objMLClass.deleteRecord();

        objMLClass.strDelete = 'Staff';
        objMLClass.lstMStaff[0].isDelete  = true;
        objMLClass.deleteRecord();

        objMLClass.strDelete = 'Company';
        objMLClass.lstMCompany[0].isDelete  = true;
        objMLClass.deleteRecord();

    }

    static testMethod void SL_LIB22_MeetingLog_New_Event_MainCancelRecordCase()
    {
        createTestRecords();

        // Valid Id
        apexpages.currentPage().getParameters().put('id',objEvent.Id);
        apexpages.currentPage().getParameters().put('isWhat','Event');
        apexpages.currentPage().getParameters().put('retURL','/'+objTestAccount.Id);

        SL_LIB22_MeetingLog_New objMLClass = new SL_LIB22_MeetingLog_New();
        objMLClass.mainCancel();

        // Null as ID
        apexpages.currentPage().getParameters().put('id',null);
        apexpages.currentPage().getParameters().put('isWhat','Event');
        apexpages.currentPage().getParameters().put('retURL','/'+objTestAccount.Id);

        SL_LIB22_MeetingLog_New objMLClass1 = new SL_LIB22_MeetingLog_New();
        objMLClass1.mainCancel();
    }

     static testMethod void SL_LIB22_MeetingLog_New_Event_MainCancelRecordCase_Home()
    {
        // Home Tab
        SL_LIB22_MeetingLog_New objMLClass2 = new SL_LIB22_MeetingLog_New();
        objMLClass2.mainCancel();
    }

    static testMethod void SL_LIB22_MeetingLog_New_Task_MainCancelRecordCase()
    {
        createTestRecords();

        // Valid Id
        apexpages.currentPage().getParameters().put('id',objTask.Id);
        apexpages.currentPage().getParameters().put('isWhat','Task');
        apexpages.currentPage().getParameters().put('retURL','/'+objTestAccount.Id);

        SL_LIB22_MeetingLog_New objMLClass = new SL_LIB22_MeetingLog_New();
        objMLClass.mainCancel();

        // Null as ID
        apexpages.currentPage().getParameters().put('id',null);
        apexpages.currentPage().getParameters().put('isWhat','Task');
        apexpages.currentPage().getParameters().put('retURL','/'+objTestAccount.Id);

        SL_LIB22_MeetingLog_New objMLClass1 = new SL_LIB22_MeetingLog_New();
        objMLClass1.mainCancel();
    }

    static testMethod void SL_LIB22_MeetingLog_New_Task_MainCancelRecordCase_Home()
    {
        // Home Tab
        SL_LIB22_MeetingLog_New objMLClass2 = new SL_LIB22_MeetingLog_New();
        objMLClass2.mainCancel();
    }

    static testMethod void SL_LIB22_MeetingLog_New_Task_Redirect()
    {
    	objMultiConnect = new SL_MultiConnect__c();
        objMultiConnect.CopyTask__c = true;
        objMultiConnect.Create_Events__c = true;
        objMultiConnect.Create_Tasks__c = true;
        objMultiConnect.Custom_Lookup_Related_To__c = true;
        objMultiConnect.FollowUp_Task__c = true;
        objMultiConnect.Name = 'Multi-Connect';
        objMultiConnect.Sent_an_Email__c = true;
        objMultiConnect.PDF_Report__c = true;
        insert objMultiConnect;

        objTestAccount = new Account();
        objTestAccount.Name = 'Test Account';
        insert objTestAccount;

        objTestContactEmployee = new Contact();
        objTestContactEmployee.LastName = 'Contact Employee 1';
        objTestContactEmployee.AccountId = objTestAccount.Id;
        insert objTestContactEmployee;

        objTask = new Task();
        objTask.Subject = 'Test Event Record 1';
        objTask.Status = 'Closed';
        objTask.ActivityDate = Date.today();
        objTask.WhatId = objTestAccount.Id;
        objTask.WhoId = objTestContactEmployee.Id;
        insert objTask;

        apexpages.currentPage().getParameters().put('id',objTask.Id);
        apexpages.currentPage().getParameters().put('isWhat','Task');

        SL_LIB22_MeetingLog_New objMLClass1 = new SL_LIB22_MeetingLog_New();

        // Edit Case
        objMLClass1.RedirectTaskEdit();

        //Detail Case
        objMLClass1.RedirectTaskDetail();
    }

    static testMethod void SL_LIB22_MeetingLog_New_Event_RedirectEdit()
    {
    	objMultiConnect = new SL_MultiConnect__c();
        objMultiConnect.CopyTask__c = true;
        objMultiConnect.Create_Events__c = true;
        objMultiConnect.Create_Tasks__c = true;
        objMultiConnect.Custom_Lookup_Related_To__c = true;
        objMultiConnect.FollowUp_Task__c = true;
        objMultiConnect.Name = 'Multi-Connect';
        objMultiConnect.Sent_an_Email__c = true;
        objMultiConnect.PDF_Report__c = true;
        insert objMultiConnect;

        objTestAccount = new Account();
        objTestAccount.Name = 'Test Account';
        insert objTestAccount;

        objTestContactEmployee = new Contact();
        objTestContactEmployee.LastName = 'Contact Employee 1';
        objTestContactEmployee.AccountId = objTestAccount.Id;
        insert objTestContactEmployee;

        objEvent = new Event();
        objEvent.Subject = 'Test Event Record 1';
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now() + 1;
        objEvent.WhatId = objTestAccount.Id;
        objEvent.WhoId = objTestContactEmployee.Id;
        insert objEvent;

        apexpages.currentPage().getParameters().put('id',objEvent.Id);
        apexpages.currentPage().getParameters().put('isWhat','Event');

        // Edit Case
        SL_LIB22_MeetingLog_New objMLClass1 = new SL_LIB22_MeetingLog_New();
        objMLClass1.RedirectEventEdit();

        //Detail Case
        objMLClass1.RedirectEventDetail();
    }

    static testMethod void SL_LIB22_MeetingLog_SendEmail()
    {
    	createTestRecords();

    	Apexpages.currentPage().getParameters().put('Id', objEvent.Id);
        Apexpages.currentPage().getParameters().put('MLogId', objTestMeetingLog.Id);

        SL_LIB22_MeetingLog_SendEmail objClass = new SL_LIB22_MeetingLog_SendEmail();
        objClass.strSearch = 'A';
        objClass.getlstResult();

        objClass.searchResults();

        objClass.strSelectOption = 'Public Group';
        objClass.getlstResult();

        objClass.fetchProfiles();

        objClass.strSelectOption = 'User';
        objClass.setSelectedProfiles();

        objClass.strSelectOption = 'Public Group';
        objClass.setSelectedProfiles();

        objClass.strSelectOption = 'User';
        objClass.strSearch = 'A';
        List<String> strSelect = new List<String>();
        strSelect.add('<option> User :  Aaron Schaechterle </option>');
        objClass.strLeftSelected = strSelect;

        //objClass.strSelected = '<option> User :  Aaron Schaechterle </option>';
        objClass.setSelectedProfiles();

        objClass.strSelectOption = 'User';

        objClass.setSelectedProfiles();
        objClass.removeSelectedProfiles();
        objClass.sendEmail();
        objClass.removeSelectedProfiles();
    }

    static testMethod void SL_LIB22_MeetingSObject_Controller()
    {
    	createTestRecords();
    	SL_LIB22_MeetingSObject_Controller objClass = new SL_LIB22_MeetingSObject_Controller();
    	objClass.setstrSObjectName('MeetingAttendee__c');
    	objClass.setstrSObjectMLogId(objTestMeetingLog.Id);
    	objClass.getstrSObjectName();
    	objClass.getstrSObjectMLogId();
    	objClass.strSObjectId = objTestMeetingAttendee.Id;

    	objClass.deleteSObjectRecord();
    }

    static testMethod void SL_LIB22_MeetingSObj_NoRecord_Controller()
    {
    	createTestRecords();
    	SL_LIB22_MeetingSObj_NoRecord_Controller objClass = new SL_LIB22_MeetingSObj_NoRecord_Controller();
    	objClass.setstrSObjectName('MeetingAttendee__c');
    	objClass.getstrSObjectName();

    }

    static testMethod void cover_SL_RelatedToCustomLookup()
 	{
 		objTestAccount = new Account();
        objTestAccount.Name = 'Test Account';
        insert objTestAccount;

 		Test.StartTest();
 		ApexPages.currentPage().getParameters().put('likeString','Account');
 		SL_LIB22_RelatedToCustomLookup bu = new SL_LIB22_RelatedToCustomLookup();
 		bu.strSearch = 'Test';
 		bu.searchRelatedTo();
 		Test.StopTest();
 	}


}