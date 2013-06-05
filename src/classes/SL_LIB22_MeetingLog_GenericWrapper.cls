global class SL_LIB22_MeetingLog_GenericWrapper
{
    public Sobject objSObject {get;set;}
    public String strSObjectId {get;set;} // Contact, Contact, Account Id
    public String strSObjectName {get;set;} // Contact, Contact, Account Name
    public String strMSobjectId {get;set;}
    public Boolean isDelete{get;set;}

    global SL_LIB22_MeetingLog_GenericWrapper()
    {
        strMSobjectId = '';
        strSObjectId = '';
        strSObjectName = '';
        isDelete=  false;
    }

    global SL_LIB22_MeetingLog_GenericWrapper(Sobject paramSObject)
    {
        strMSobjectId = '';
        strSObjectId = '';
        strSObjectName = '';

        objSObject = paramSObject;
        if(paramSObject != NULL && paramSObject.Id != NULL)
        {
        	String strSObjectName = String.valueOf(Id.valueOf(paramSObject.Id).getSObjectType());
            strMSobjectId = paramSObject.Id;
         	strSObjectId =  String.valueOf(paramSObject.get(SL_LIB22_MeetingLog_Utils.loadMapSObject_MDFieldData().get(strSObjectName)));
         	//strSObjectName =  String.valueOf(paramSObject.get(SL_LIB22_MeetingLog_Utils.loadMapSObject_QueryFieldData().get(strSObjectName)));
        }

        isDelete=  false;
    }
}