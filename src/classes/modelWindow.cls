public with sharing class modelWindow {
	
	public Boolean blnShowHide {get;set;} 
	
	public modelWindow()
	{
		blnShowHide = false; 
	}
	
	public void clickBtn()
	{
		/// do something;
		
		if(blnShowHide)
			blnShowHide = false;
		else
			blnShowHide = true;
		system.debug('---temp---'+blnShowHide);
		
	}
}