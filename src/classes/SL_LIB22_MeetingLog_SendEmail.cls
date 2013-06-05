public with sharing class SL_LIB22_MeetingLog_SendEmail
{
	public Task objTask {get;set;}
	public Event objEvent {get;set;}

	public String strId {get;set;}
	public String strMeetingLog {get;set;}

	// Email
	public String strSelectOption {get;set;}
	public String strMeetingSubject {get;set;}
	public String strMeetingBody {get;set;}

	public String strSearch {get;set;}

	public Set<String> setAllPresent {get;set;}
    public Set<String> setAllPresentName {get;set;}

    public List<SelectOption> selectedlstResult {get;set;}
    public List<SelectOption> selectedlstResultRight {get;set;}
    public List<String> strRightSelected {get;set;}
    public List<String> strLeftSelected {get;set;}

	public SL_LIB22_MeetingLog_SendEmail()
    {
        try
        {
            initialise();
            strId = Apexpages.currentPage().getParameters().get('Id');
            strMeetingLog = Apexpages.currentPage().getParameters().get('MLogId');

            strSelectOption = 'User';

            if(strId != '' && strId != NULL)
            {
            	if(String.valueOf(Id.valueOf(strId).getSObjectType()) == 'Task')
            	{
                	objTask =  [select Subject, ActivityDate from Task where id =: strId];
                	strMeetingSubject = 'Meeting Note Attached : ' + objTask.Subject ;
                	strMeetingBody = 'The Meeting Note Report from ' + objTask.Subject + ' is attached';
            	}
                else if(String.valueOf(Id.valueOf(strId).getSObjectType()) == 'Event')
                {
                	objEvent =  [select Subject, ActivityDate from Event where id =: strId];
                	strMeetingSubject = 'Meeting Note Attached : ' + objEvent.Subject;
                	strMeetingBody = 'The Meeting Note Report from ' + objEvent.Subject +' is attached';
                }
            }
        }
        catch(Exception e)
        {

        }
    }

    public void initialise()
    {
        strSelectOption = '';
        strMeetingSubject = '';
        strMeetingLog = '';
        strId = '';
        strSearch = '';
        strMeetingBody = '';
        strMeetingLog = '';

        strRightSelected = new List<String>();
        strLeftSelected = new List<String>();
        setAllPresent = new Set<String>();
    	setAllPresentName = new Set<String>();

    	selectedlstResult = new List<Selectoption>();
    }

    public List<SelectOption> getlstResult()
    {
        try
        {
            List<SelectOption> options = new List<SelectOption>();

            setAllPresent = new Set<String>();
            setAllPresentName = new Set<String>();
            for(Selectoption objSO : selectedlstResult)
            {
                setAllPresent.add(objSO.getValue());
                String strTemp = objSO.getLabel();
                strTemp = strTemp.substring(strTemp.indexof(':') + 2, strTemp.length());
                setAllPresentName.add(strTemp);
            }

            if(strSelectOption == 'User')
            {
                for(User objUser : [Select Name, Email from User where Name != NULL AND Name like: '%' +strSearch + '%' AND Name NOT IN: setAllPresentName AND isActive = true ORDER BY Name ])
                {
                    if(objUser.Name != NULL)
                        options.add(new SelectOption(objUser.Email, 'User : ' + objUser.Name));
                }
            }
            else if(strSelectOption == 'Public Group')
            {
                for(Group objGroup : [Select Id, Name from Group where Name != NULL AND Name like: '%' +strSearch + '%'  AND Id NOT IN: setAllPresent ORDER BY Name])
                {
                    if(objGroup.Name != NULL)
                        options.add(new SelectOption(objGroup.Id, 'Public Group : ' + objGroup.Name));
                }
            }
            return options;
        }
        catch(Exception e)
        {
            // do nothing
            return null;
        }
    }

    public void searchResults()
    {
        try
        {
            getlstResult();
        }
        catch(Exception e)
        {
            // do nothing
        }
    }

    public void fetchProfiles()
    {
        try
        {
            getlstResult();
        }
        catch(Exception e)
        {
            // do nothing
        }
    }

    public void removeSelectedProfiles()
    {
        try
        {
    		List<String> lstUsers = new List<String>();
            Set<String> setUsers = new Set<String>();
            Set<String> setUserPresent = new Set<String>();
            List<String> lstGroups = new List<String>();
            Set<String> setGroups = new Set<String>();
            Set<String> setGroupsPresent = new Set<String>();

            lstUsers = strLeftSelected;

            for(String strTemp : lstUsers)
            {
                setUsers.add(strTemp);
            }

            for(Selectoption objSO : selectedlstResult)
            {
                setUserPresent.add(objSO.getValue());
            }

            lstGroups = strLeftSelected;

            for(String strTemp : lstGroups)
            {
            	setGroups.add(strTemp);
            }

            for(Selectoption objSO : selectedlstResult)
            {
                setGroupsPresent.add(objSO.getValue());
            }

            selectedlstResult = new List<Selectoption>();
            for(User objUser : [Select Name, Email from User where Email NOT IN: setUsers AND Email IN : setUserPresent AND isActive= true ORDER BY NAME])
            {
                selectedlstResult.add(new SelectOption(objUser.Email, 'User : ' + objUser.Name));
            }

            for(Group objGroup : [Select Id, Email, Name from Group where Id NOT IN: setGroups AND Id IN : setGroupsPresent ORDER BY Name])
            {
                selectedlstResult.add(new SelectOption(objGroup.Id, 'Public Group : ' + objGroup.Name));
            }

            getlstResult();

        }
        catch(Exception e)
        {

        }
    }

    public void setSelectedProfiles()
    {
        try
        {
            if(strSelectOption == 'User')
            {
                List<String> lstUsers = new List<String>();
                Set<String> setUsers = new Set<String>();

                lstUsers = strRightSelected;

                for(String strTemp : lstUsers)
                {
                    setUsers.add(strTemp);
                }

                for(User objUser : [Select Name, Email from User where Email IN: setUsers AND isActive = true ORDER BY NAME])
                {
                    selectedlstResult.add(new SelectOption(objUser.Email, 'User : ' + objUser.Name));
                }

                getlstResult();

            }
            else if(strSelectOption == 'Public Group')
            {
                List<String> lstGroups = new List<String>();
                Set<String> setGroups = new Set<String>();

                lstGroups = strRightSelected;

                for(String strTemp : lstGroups)
                {
                	setGroups.add(strTemp);
                }

                for(Group objGroup : [Select Id, Email, Name from Group where Id IN: setGroups ORDER BY Name])
                {
                    selectedlstResult.add(new SelectOption(objGroup.Id, 'Public Group : ' + objGroup.Name));
                }

                getlstResult();
            }
        }
        catch(Exception e)
        {
            // do nothing;
        }
    }


    public PageReference sendEmail()
    {
        try
        {
            List<String> lstEMailsToSend = new List<String>();
            Set<String> setGroupIds = new Set<String>();
            Set<String> setEMail = new Set<String>();
            for(Selectoption objSO : selectedlstResult)
            {
            	if(objSO.getValue().contains('.com'))
                	setEMail.add(objSO.getValue());
                setGroupIds.add(objSO.getValue());
            }
            if(setEMail.size() > 0)
                lstEMailsToSend.addAll(setEMail);
            // fetch all group Members
            List<GroupMember> lstGM = new List<GroupMember>();
            Set<Id> setGMUserIds = new Set<Id>();
            lstGM = [Select g.UserOrGroupId, g.GroupId, Group.Name From GroupMember g where GroupId IN: setGroupIds];

            // Fetch all members of the Group
            for(GroupMember objGM : lstGM)
            {
                setGMUserIds.add(objGM.UserOrGroupId);
            }

            // Fetch all user which are currenlty present in Group
            for(User objU : [Select Id, Email from User where Id IN: setGMUserIds AND isActive = true])
            {
                lstEMailsToSend.add(objU.Email);
            }

            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            // Reference the attachment page and pass in the account ID
            PageReference pdf = Page.SL_LIB22_MeetingLog_Report;
            pdf.getParameters().put('Id',strId);
            pdf.getParameters().put('MLogId', strMeetingLog);
            pdf.setRedirect(true);
            Blob b;
            // Take the PDF content
            if(!Test.isRunningTest())
             b = pdf.getContentasPDF();

            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('MeetingNoteReport.pdf');
            if(Test.isRunningTest())
            {
             b =  Blob.valueOf('Test Blob');
            }

            efa.setBody(b);

            email.setToAddresses(lstEMailsToSend); // lstEMailsToSend all selected users or Public group
            email.setSenderDisplayName('Meeting Note');
            email.setSubject(strMeetingSubject);
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            sfdcBaseURL = sfdcBaseURL + '/apex/SL_LIB22_MeetingLog_Detail?id=' + strId;
            String strHtmlBody = '<html><body>'+ strMeetingBody +' <br/> <br/> <a href=" '+ sfdcBaseURL +'"> Click here to access the Meeting Note in Salesforce </a> </body></html>';
            email.setHtmlBody(strHtmlBody);
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

            return new pageReference('/' +strId);
        }
        catch(Exception e)
        {
            // do nothing
            return null;
        }
    }
}