public with sharing class sampleDatePicker {

	public String dateValue {get; set;}
	public string formatedDate='';
	public sampleDatePicker()
	{
		// do something;
	} 
	
	public string getValue()
	{
		Datetime cDT = System.now();
    	formatedDate = cDT.format('M/d/yyyy');
		return formatedDate;
	}
}