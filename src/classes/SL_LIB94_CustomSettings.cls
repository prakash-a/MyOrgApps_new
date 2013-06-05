public class SL_LIB94_CustomSettings {
	
	/*
		
	*/
	public String strTestHierarchy 	{ get; set; }
	public String strTestList 	{ get; set; }
	
	// Constructor of the class
	public SL_LIB94_CustomSettings()
	{
		strTestHierarchy = getCustomSettingHierarchy().getcustomSettigsHierarchyField();
		strTestList = getCustomSettingList('Test List').customSettigsListField;
		
	}
	
	/**
		Hierarchy custom settings 
	*/
	private static customSettingsHirarchy testCustomSettingHirarchy = null;
        
    public static customSettingsHirarchy getCustomSettingHierarchy() {
        
        if (testCustomSettingHirarchy == null) {
            testCustomSettingHirarchy = new customSettingsHirarchy();
        }   
        return testCustomSettingHirarchy;
    }
       
    public class customSettingsHirarchy
    {
        // Custom setting fields declaration
	    //public string customSettigsHierarchyField    { get; set; }
	    private string customSettigsHierarchyField;
	    // End custom settings declartion
        
        public customSettingsHirarchy() {
            try{
	            // Custom setting create instance
	            TestHierarchy__c setting = TestHierarchy__c.getInstance();
	            // End create instance
	          
	            if (setting != null) {
	                // Assigning the custom setting fields
	                customSettigsHierarchyField = setting.Test_Hierarchy__c;
	                // End assigning the custom setting fields
	            }
	                
	            if (customSettigsHierarchyField == null || customSettigsHierarchyField == '')
	                customSettigsHierarchyField = 'Test Hierarchy data';
            }
           	catch(Exception ex)
			{
				system.debug('========Exception==========>>>'+ex.getlinenumber()+'===='+ex);
			}
	    }
         
        public String getcustomSettigsHierarchyField()
		{
			return customSettigsHierarchyField;
		}
	    
    }
    
    /*
    	List custom settings
    */
    private static customSettingsList testCustomSettingList = null;
        
    public static customSettingsList getCustomSettingList(string str) {
        
        if (testCustomSettingList == null) {
            testCustomSettingList = new customSettingsList(str);
        }   
        return testCustomSettingList;
    }
    
    public class customSettingsList
    {
        // Custom setting fields declaration
	    private string customSettigsListField;
	    private Map<String, Test1__c> setting{ get; set; }
	    // End custom settings declartion
        
        public customSettingsList(string str) {
            try{
	            // Custom setting create instance
	            setting = Test1__c.getAll();
	            
	            if (setting != null) {
	                // Assigning the custom setting fields
	                customSettigsListField = setting.get(str).Test_Hierarchy__c;
	                // End assigning the custom setting fields
	            }
	           	
	            if (customSettigsListField == null || customSettigsListField == '')
	                customSettigsListField = 'Test List data';
	        
        	}
           	catch(Exception ex)
			{
				system.debug('========Exception==========>>>'+ex.getlinenumber()+'===='+ex);
			}
        }
        
        public String getcustomSettigsListField()
		{
			return customSettigsListField;
		}
    }
}