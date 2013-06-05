@RestResource(urlmapping='/showAccounts/*')  
global class restService
{
	@httpget
	global static list<Account> getAccounts()
	{
		list<Account> lst;
		try{
			lst = [select Name from Account limit 10];
			return lst;
		}
		catch(Exception e){
			system.debug('Error:'+e.getMessage());
		}
		return lst;
	}
}