public with sharing class SL_LIB22_MeetingSObject_Controller
{
    public String strSObjectName;
    public String strSObjectMLogId;
    public String strSObjectId {get;set;}
    public Map<String, String> mapSObject_FieldSetName;
    public Map<String, String> mapSObject_QueryFieldName;
    public List<String> lstFields {get;set;}

    public Map<String, String> mapFieldAPI_Label {get;set;}
    public List<SL_LIB22_MeetingLog_GenericWrapper> lstSObject {get;set;}

    public String getstrSObjectName()
    {
        loadFieldFromFieldSet();
        loadFieldAPI_Labels();
        return strSObjectName;
    }

    public String setstrSObjectName(String paramSObjectName)
    {
        strSObjectName = paramSObjectName;
        return strSObjectName;
    }

    public String getstrSObjectMLogId()
    {
        loadMeetingLogSObjectData();
        return strSObjectMLogId;
    }

    public String setstrSObjectMLogId(String paramSObjectMLogId)
    {
        strSObjectMLogId = paramSObjectMLogId;
        return strSObjectMLogId;
    }

    public SL_LIB22_MeetingSObject_Controller()
    {
        initialise();
        mapSObject_FieldSetName = SL_LIB22_MeetingLog_Utils.loadMapSObject_FieldSetData();
        mapSObject_QueryFieldName = SL_LIB22_MeetingLog_Utils.loadMapSObject_QueryFieldData();
    }

    private void initialise()
    {
        strSObjectName = '';
        strSObjectMLogId = '';
        strSObjectId = '';
        mapSObject_FieldSetName = new Map<String, String>();
        mapSObject_QueryFieldName = new Map<String, String>();
        mapFieldAPI_Label = new Map<String, String>();
        lstFields = new List<String>();
        lstSObject = new List<SL_LIB22_MeetingLog_GenericWrapper>();
    }

    private void loadFieldFromFieldSet()
    {
        lstFields = SL_LIB22_MeetingLog_Utils.createListFieldAPI(strSObjectName, mapSObject_FieldSetName.get(strSObjectName));
    }

    private void loadFieldAPI_Labels()
    {
        mapFieldAPI_Label = SL_LIB22_MeetingLog_Utils.createMapFieldAPI_Label(strSObjectName, mapSObject_FieldSetName.get(strSObjectName));
    }

    private void loadMeetingLogSObjectData()
    {
        lstSObject = new List<SL_LIB22_MeetingLog_GenericWrapper>();
        for(SObject objMSObject : Database.query(SL_LIB22_MeetingLog_Utils.createQueryString(strSObjectName, mapSObject_FieldSetName.get(strSObjectName) , mapSObject_QueryFieldName.get(strSObjectName), strSObjectMLogId)))
        {
            SL_LIB22_MeetingLog_GenericWrapper obj = new SL_LIB22_MeetingLog_GenericWrapper(objMSObject);
            lstSObject.add(obj);
        }
    }

    public void deleteSObjectRecord()
    {
		Sobject objSObject;
		Schema.SObjectType ObjType = Schema.getGlobalDescribe().get(String.valueOf(Id.valueOf(strSObjectId).getSObjectType()));
		objSObject = ObjType.newSobject();

		objSObject.Id = Id.valueOf(strSObjectId);

		delete objSObject;

    }




}