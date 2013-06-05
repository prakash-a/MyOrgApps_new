public with sharing class SL_LIB22_MeetingLog_Redirect
{
    public Task objTask {get;set;}
    public Event objEvent {get;set;}
    public String strCheck {get;set;}
    public boolean isBlankTask {get;set;}
    public String strReturnUrl {get;set;}
    public String strId {get;set;}
    public String strWhoId {get;set;}
	public String strWhatId {get;set;}

    public SL_LIB22_MeetingLog_Redirect(Apexpages.standardController std)
    {
        try
        {
            objTask = new Task();
            objEvent = new Event();
            strCheck = '';
            isBlankTask = false;
            strReturnUrl = '';
            strWhoId = '';
			strWhatId = '';

            if(Apexpages.currentPage().getParameters().containsKey('what_id'))
				strWhatId = Apexpages.currentPage().getParameters().get('what_id');

			if(Apexpages.currentPage().getParameters().containsKey('who_id'))
				strWhoId = Apexpages.currentPage().getParameters().get('who_id');

			if(Apexpages.currentPage().getParameters().containsKey('retURL'))
				strReturnUrl = Apexpages.currentPage().getParameters().get('retURL');

            if(!Apexpages.currentPage().getParameters().containsKey('what_id') && !Apexpages.currentPage().getParameters().containsKey('who_id') && !ApexPages.currentPage().getParameters().containsKey('id'))
                isBlankTask = true;

            if(!isBlankTask)
            {
                // Store all the URL Parameters Like Return URL, Task ID, WhatID and WhoID.
                strId = apexPages.currentPage().getParameters().get('id');
                strReturnUrl = apexPages.currentPage().getParameters().get('retURL');
                String strIdTemp = '';
                strIdTemp = strId.subString(0,3);

                // Checking Id is of Task or Event
                if(strIdTemp == '00T') // Checking Task Id
                {
                    // checking with the Task is not NULL and fetching its record
                    if(strId != '' && strId != null )
                    {
                        String taskFields = SL_LIB22_MeetingLog_Utils.fetchAllTaskFields();
                        List<SObject> objRecord = new List<SObject>();
                        objRecord= Database.query(' Select ' + taskFields  + ' from Task where id=\'' + strId + '\'');
                        objTask =  (objRecord.size() > 0) ? (Task)objRecord[0] : new Task();

                    }
                }
                else if(strIdTemp == '00U') // Checking Event Id
                {
                    // Event Redirect Object.
                    if(strId != '' && strId != null )
                    {
                        String eventFields = SL_LIB22_MeetingLog_Utils.fetchAllEventFields();
                        List<SObject> objRecord = new List<SObject>();
                        objRecord= Database.query(' Select ' + eventFields  + ' from Event where id=\'' + strId + '\'');
                        objEvent =  (objRecord.size() > 0) ? (Event)objRecord[0] : new Event();
                    }
                }

            }
        }
        catch(Exception e)
        {
            // do nothing
        }
    }

    public PageReference RedirectTaskEdit()
    {
        try
        {
            String pageRefParam = '';
            // Redirecting to VF Page if Task record is having Meeting Log Boolean true
            if(objTask.Meeting_Log__c == true)
            {
                pageRefParam = '/apex/SL_LIB22_MeetingLog_New?id='+ objTask.Id+'&isWhat=Task';
                PageReference objPageRef = new PageReference(pageRefParam);
                objPageRef.setRedirect(true);
                return objPageRef;
            }
            else // Redirecting to Standard Task Page
            {
                PageReference newPage;
                newPage = new PageReference('/' + strId + '/e' + '?retURL=' + strReturnUrl);
                newPage.getParameters().put('nooverride', '1');
                return newPage.setRedirect(true);
            }
        }
        catch(Exception e)
        {
            // do nothing
            return null;
        }
    }

    /* Start - Function Function RedirectTaskDetail */
         public PageReference RedirectTaskDetail()
         {
            try
            {
                String pageRefParam = '';
                // Redirecting to VF Page for Task Detail page
                if(objTask.Meeting_Log__c == true)
                {
                    pageRefParam = '/apex/SL_LIB22_MeetingLog_Detail?id='+ objTask.Id+'&isWhat=Task' ;
                    PageReference objPageRef = new PageReference(pageRefParam);
                    objPageRef.setRedirect(true);
                    return objPageRef;
                }
                else // Redirecting to Standard Task Detail Page
                {
                    PageReference newPage;
                    newPage = new PageReference('/' + strId + '?retURL=' + strReturnUrl);
                    newPage.getParameters().put('nooverride', '1');
                    return newPage.setRedirect(true);
                }
            }
            catch(Exception e)
            {
                // do nothing
                return null;
            }
         }

    /* End - Function RedirectTaskDetail */

    public PageReference RedirectEventEdit()
    {
        try
        {
            String pageRefParam = '';
            // Redirecting to VF Page of Event Edit Link Button.
            if(objEvent.Meeting_Log__c == true)
            {
                pageRefParam = '/apex/SL_LIB22_MeetingLog_New?id='+ objEvent.Id+'&isWhat=Event';
                PageReference objPageRef = new PageReference(pageRefParam);
                objPageRef.setRedirect(true);
                return objPageRef;
            }
            else // Redirecting to Standard Event Edit Page
            {
                PageReference newPage;
                newPage = new PageReference('/' + strId + '/e' + '?retURL=' + strReturnUrl);
                newPage.getParameters().put('nooverride', '1');
                return newPage.setRedirect(true);
             }
        }
        catch(Exception e)
        {
            // do nothing
            return null;
        }
    }

    /* Start - Function Function RedirectTaskDetail */
         public PageReference RedirectEventDetail()
         {
            try
            {
                String pageRefParam = '';
                // Redirecting to VF Page of Event View Link
                if(objEvent.Meeting_Log__c == true)
                {
                    pageRefParam = '/apex/SL_LIB22_MeetingLog_Detail?id='+ objEvent.Id+'&isWhat=Event' ;
                    PageReference objPageRef = new PageReference(pageRefParam);
                    objPageRef.setRedirect(true);
                    return objPageRef;
                }
                else // Redirecting to Standard Event Detail Page.
                {
                    PageReference newPage;
                    newPage = new PageReference('/' + strId + '?retURL=' + strReturnUrl);
                    newPage.getParameters().put('nooverride', '1');
                    return newPage.setRedirect(true);
                }
            }
            catch(Exception e)
            {
                // do nothing
                return null;
            }
         }

    /* End - Function RedirectTaskDetail */

}