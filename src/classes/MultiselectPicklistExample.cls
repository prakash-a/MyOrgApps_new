public with sharing class MultiselectPicklistExample {
 	public List<string> selectedContacts { get; set; }
    public List<string> allContacts { get; set; }
    
    public String message { get; set; }
    
    public MultiselectPicklistExample() {
        selectedContacts = new List<string>(); //List<SelectOption>();
        
        List<Contact> contacts = [SELECT Name, Id FROM Contact LIMIT 10];    
        allContacts = new  List<string>();//List<SelectOption>();
        for ( Contact c : contacts ) {
        	//system.debug('-----' + c.Name);
            allContacts.add(string.escapeSingleQuotes(c.Name)); //(new SelectOption(c.Id, c.Name));
        }
    }
	/*
    public PageReference save() {
        message = 'Selected Contacts: ';
        Boolean first = true;
        for ( SelectOption so : selectedContacts ) {
            if (!first) {
                message += ', ';
            }
            message += so.getLabel() + ' (' + so.getValue() + ')';
            first = false;
        }
        
        return null;       
    }
    */
}