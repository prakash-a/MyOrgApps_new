public with sharing class SL_LIB22_MeetingSObj_NoRecord_Controller
{
	public String strSObjectName;
	public Map<String, String> mapSObject_FieldSetName;
    public Map<String, String> mapSObject_QueryFieldName;

	public List<String> lstFields {get;set;}
    public Map<String, String> mapFieldAPI_Label {get;set;}

	public String setstrSObjectName(String paramSObjectName)
    {
        strSObjectName = paramSObjectName;
        return strSObjectName;
    }

	public String getstrSObjectName()
    {
        loadFieldFromFieldSet();
        loadFieldAPI_Labels();
        return strSObjectName;
    }

    public SL_LIB22_MeetingSObj_NoRecord_Controller()
    {
        initialise();
        mapSObject_FieldSetName = SL_LIB22_MeetingLog_Utils.loadMapSObject_FieldSetData();
        mapSObject_QueryFieldName = SL_LIB22_MeetingLog_Utils.loadMapSObject_QueryFieldData();
    }

    private void initialise()
    {
        strSObjectName = '';
        mapSObject_FieldSetName = new Map<String, String>();
        mapSObject_QueryFieldName = new Map<String, String>();
        mapFieldAPI_Label = new Map<String, String>();
        lstFields = new List<String>();
    }

    private void loadFieldFromFieldSet()
    {
        lstFields = SL_LIB22_MeetingLog_Utils.createListFieldAPI(strSObjectName, mapSObject_FieldSetName.get(strSObjectName));
    }

    private void loadFieldAPI_Labels()
    {
        mapFieldAPI_Label = SL_LIB22_MeetingLog_Utils.createMapFieldAPI_Label(strSObjectName, mapSObject_FieldSetName.get(strSObjectName));
    }
}