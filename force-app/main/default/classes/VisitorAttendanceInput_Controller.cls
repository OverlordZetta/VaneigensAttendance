public without sharing class  VisitorAttendanceInput_Controller {
    
    Public Static Final String VisitorRT =  'Visitor_Attendance';
    Public Static Final String vaneigensAccount = 'Vaneigens';
    public static Final Id RT_Visitor = Schema.SObjectType.Day_in_the_office__c.getRecordTypeInfosByDeveloperName().get(VisitorRT).getRecordTypeId();
    
    @AuraEnabled(Cacheable=false)
    public  static void saveAttendance(String email, String firstName, String lastName, Date attendanceDate){
        
        Contact visitor = new Contact(firstName = firstName, LastName = lastName, Email = email);
        //Check Contact existance
        List<Contact> c = [Select id,FirstName,Salutation, LastName, Email from Contact where email = :visitor.email];
        if(c.size()==0){
            Account acc = [Select id From Account where Name = : vaneigensAccount];
            visitor.accountId = acc.Id;
            insert visitor;
        }
        else {
            visitor.Id = c[0].Id;
            update visitor;
        }
        
        Day_In_The_Office__c attendance = new Day_In_The_Office__c(RecordTypeId=RT_Visitor, Visitor__c = visitor.Id,
        Attendance_Date__c = attendanceDate);
        
        insert attendance;
        
        
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static void getAttendances(String email){
        List<Day_In_The_Office__c> attendances =  [Select id, Visitor__r.Email, Visitor__r.Name, unique_identifier__c, Attendance_Date__c from Day_In_The_Office__c 
        where Visitor__r.Email = : email
        ORDER BY Attendance_Date__c DESC];
    }    
    
    
    
}