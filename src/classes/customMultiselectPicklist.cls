public with sharing class customMultiselectPicklist {
	/*
	String[] countries = new String[]{};
	public PageReference test() {
		return null;
	}
	public List<SelectOption> getItems() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('US','US'));
		options.add(new SelectOption('CANADA','Canada'));
		options.add(new SelectOption('MEXICO','Mexico'));
		return options;
	}
	public String[] getCountries() {
		return countries;
	}
	public void setCountries(String[] countries) {
		this.countries = countries;
	}
	*/
/*
    // SelectOption lists for public consumption
    public List<SelectOption> leftOptions { get; set; }
    public List<SelectOption> rightOptions { get; set; }
    
    // Parse &-separated values and labels from value and 
    // put them in option
    private void setOptions(SelectOption[] options, String value) {
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
              EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
    }
    
    // Backing for hidden text field containing the options from the
    // left list
    public String leftOptionsHidden { get; set {
           leftOptionsHidden = value;
           setOptions(leftOptions, value);
        }
    }
    
    // Backing for hidden text field containing the options from the
    // right list
    public String rightOptionsHidden { get; set {
           rightOptionsHidden = value;
           setOptions(rightOptions, value);
        }
    }
*/
    ///////////////////////////////////////////////// other code 
    
    //Set<String> originalvalues = new Set<String>{'A','B','C','D','E','F','G'};
    public List<string> leftselected;
    public List<string> rightselected{get;set;}
    public List<string> leftvalues = new List<string>();
    public List<string> rightvalues = new List<string>();
    
    public String sortTypeParam{get;set;}
     
    public customMultiselectPicklist(){
        //left = new List<String>();
        //rightselected = new List<String>();
        //leftvalues.addAll(originalvalues);
    }
    public List<string> setlstNewLeftOptions(List<String> lst)
    {
    	leftvalues = lst;
    	return leftselected;
    }
    
    public List<string> getlstNewLeftOptions()
    {
    	return leftselected;
    }
    
    public PageReference selectclick(){
        rightselected.clear();
        integer i;
        for(String s : leftselected){
            rightvalues.add(s);
            List<string> tempLeftValues = new List<string>(leftvalues);
            i=0;
	        for(String st : tempLeftValues)
	        {
	        	if(st == s)
	        	{
	        		leftvalues.remove(i);
	        	}
	        	i++;
	        }
        }
        return null;
    }
     
    public PageReference unselectclick(){
        leftselected.clear();
        integer i;
        for(String s : rightselected){
            leftvalues.add(s);
            List<string> tempRightValues = new List<string>(rightvalues);
            i=0;
	        for(String st : tempRightValues)
	        {
	        	if(st == s)
	        	{
	        		rightvalues.remove(i);
	        	}
	        	i++;
	        }
        }
        //rightvalues.remove(rightselected);
        return null;
    }
    public PageReference sortValues(){
        //rightselected.clear();
        List<string> tempvalue = new List<string>();
        String tempString;
        integer i;
        if(sortTypeParam == 'Down')
        {
        	i=0;
        	List<string> tempReverseSelectedData = new List<string>();
        	for(String s : rightselected){
            	tempReverseSelectedData.add(rightselected.get((rightselected.size()-1)-i));
    			i++;
        	}
        	rightselected.clear();
        	rightselected.addAll(tempReverseSelectedData);
        }
        for(String s : rightselected){
            tempvalue.add(s);
            List<string> tempRightValues = new List<string>(rightvalues);
        	i=0;
	        for(String st : tempRightValues)
	        {
	        	if(st == s)
	        	{
	        		tempString = '';
	        		if(sortTypeParam == 'Up' && i != 0)
	        		{
	        			tempString = rightvalues.get(i-1);
	        			rightvalues.set(i-1,rightvalues.get(i));
	        			rightvalues.set(i,tempString);
	        		}
	        		else if(sortTypeParam == 'Down' && i < (rightvalues.size()-1))
	        		{
	        			tempString = rightvalues.get(i+1);
	        			rightvalues.set(i+1,rightvalues.get(i));
	        			rightvalues.set(i,tempString);
	        		}
	        		else if(sortTypeParam == 'Top' || sortTypeParam == 'Bottom')
	        		{
	        			rightvalues.remove(i);
	        		}
	        	}
	        	i++;
	        }
        }    
        List<string> tempList = new List<String>();
        if(sortTypeParam == 'Top')
        {
        	tempList.addAll(tempvalue);
        	tempList.addAll(rightvalues);
        }
        else if(sortTypeParam == 'Bottom')
        {
        	tempList.addAll(rightvalues);
        	tempList.addAll(tempvalue);
        }
        
        //tempList.sort();
        if(sortTypeParam == 'Top' || sortTypeParam == 'Bottom')
        {
	        rightvalues.clear();
	        rightvalues.addAll(tempList);
        }
        return null;
    } 
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        //tempList.sort();
        for(string s : tempList){
        	options.add(new SelectOption(s,s));
    	}
        return options;
    }

    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        //tempList.sort();
        for(String s : tempList){
            options1.add(new SelectOption(s,s));
    	}
        return options1;
        

    }
    
   
}