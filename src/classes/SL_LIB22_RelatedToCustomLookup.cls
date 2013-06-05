public with sharing class SL_LIB22_RelatedToCustomLookup
{
	//public string strOppId{get;set;}
	public Boolean blnSearchAllAccount {get;set;}
	public Boolean isError {get;set;}
	public String strSearch {get;set;}
	public List<Account> lstAccount {get;set;}
	public String checkRelatedTo {get;set;}

	public SL_LIB22_RelatedToCustomLookup()
    {
        try
        {
        	checkRelatedTo = '';
        	isError = blnSearchAllAccount = false;
        	lstAccount = new List<Account>();
        	checkRelatedTo = System.currentPageReference().getParameters().get('likeString');
			dispQueryRecords();
        }
        catch(exception ex)
        {
        	// do nothing.
        }
    }

    public void dispQueryRecords()
    {
    	try
    	{
	    	if(checkRelatedTo == 'Account')
	    	{
	    		lstAccount = [Select Id, Name from Account order by Name limit 1000];
	    	}
    	}
    	catch(Exception e)
    	{
    		// do nothing
    	}
    }

    public void searchRelatedTo()
    {
    	try
    	{

	    	if(strSearch != '' && strSearch != null)
	    	{
	    		if(strSearch.startsWith('*') && !strSearch.endsWith('*'))
	    			strSearch = '%' + strSearch.substring(strSearch.indexOf('*') + 1, strSearch.length());

	    		else if(strSearch.endsWith('*') && !strSearch.startsWith('*'))
	    			strSearch = strSearch.substring(0, strSearch.indexOf('*') ) + '%';

	    		else if(strSearch.startsWith('*') && strSearch.endsWith('*'))
	    		{
					strSearch = '%' + strSearch.substring(1, strSearch.length() - 1) + '%';
	    		}
	    		else
	    			strSearch = strSearch + '%';

		    	if(checkRelatedTo == 'Account')
		    	{
		    		//String strquery = 'Select Id, Name from Account where Name ='
		    		 //'SELECT '+ ? + ' FROM Account WHERE Name LIKE \'Test%\''
		    		lstAccount = [Select Id, Name from Account where Name LIKE :strSearch ORDER BY Name limit 1000];
		    	}

		    	system.debug('??????????strSearch????????????' + strSearch + ' Accuount Size ' + lstAccount.size());
	    	}
	    	else
	    	{
	    		dispQueryRecords();
	    	}
    	}
    	catch(Exception e)
    	{
    		// do nothing
    	}
    }
}