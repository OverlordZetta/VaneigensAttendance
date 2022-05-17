public without sharing class  CovidAttendance_Visitors_Controller {
    //change
    Public Static Final String VisitorRT =  'Visitor_Attendance';
    Public Static Final String vaneigensAccount = 'Vaneigens';
    public static Final Id RT_Visitor = Schema.SObjectType.Day_in_the_office__c.getRecordTypeInfosByDeveloperName().get(VisitorRT).getRecordTypeId();
    
    
    //Attendance booking
    public Contact Visitor{get;set;}
    public Date attendanceDate{get;set;}
    
    //Attendance Fetching
    public Contact attendeeContact{get;set;}
    public List<Day_In_The_Office__c> attendances {get;set;}
    public String token {get;set;}
    public Boolean authenticated {get;set;}
    
    //this is the selected row to delete
    public String attendanceIdToDelete {get;set;}
        
    public CovidAttendance_Visitors_Controller(){
        this.authenticated = false;
        Visitor = new Contact();
        attendeeContact = new Contact();
    }
    
    
    
    
    public  void saveAttendance(){
        
        //Check Contact existance
        try{
            List<Contact> c = [Select id,FirstName,Salutation, LastName, Email from Contact where email = :this.visitor.email];
            if(c.size()==0){
                Account acc = [Select id From Account where Name = : vaneigensAccount];
                this.visitor.accountId = acc.Id;
                insert this.visitor;
            }
            else {
                this.visitor.Id = c[0].Id;
                update this.visitor;
            }
            
            Day_In_The_Office__c attendance = new Day_In_The_Office__c(RecordTypeId=RT_Visitor, Visitor__c = this.visitor.Id,
                                                                       Attendance_Date__c = this.attendanceDate);
            
            insert attendance;
            
            
            //Emptying fields
            This.Visitor.id = null;
            if(this.attendeeContact.email != this.Visitor.email) {authenticated=false;this.token='';}
            this.attendeeContact = this.Visitor;
            this.AttendanceDate = null;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Attendance registred successfully'));
            
           	fetchAttendances();
            
        }
        catch(exception e){
            ApexPages.addMessages(e); 
        }
    }
    
    
    public void fetchAttendances(){
        if(!authenticated && this.token!=''){            
            List<VisitorToken__c> myTokenFetch = [Select id, Visitor__r.Email, GeneratedToken__c from VisitorToken__c
                                                                  where Visitor__r.Email = :attendeeContact.email];
            if(myTokenFetch.size()>0 && myTokenFetch[0].GeneratedToken__c == this.token) authenticated = true;
            else ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Wrong token, please check your email for the Token or generate a new one.'));
            
        }
        this.attendances = [Select id, Visitor__r.Email, Visitor__r.Name, unique_identifier__c, Attendance_Date__c from Day_In_The_Office__c where Visitor__r.Email = : attendeeContact.Email
                           ORDER BY Attendance_Date__c DESC];
    }    
    
    public void deleteAttendance() {
        Day_In_The_Office__c d = new Day_In_The_Office__c();
        d.Id = this.attendanceIdToDelete;
        delete d;
        fetchAttendances();
    }
    
    
    public void generateAuthToken(){
        
        //Verify that user exists.
        List<Contact> cons = [Select id, Email from Contact where Email =:attendeeContact.Email];
        if(cons.Size()>0){
            VisitorToken__c myToken;
            List<VisitorToken__c> myTokenFetch = [Select id, Visitor__c from VisitorToken__c
                                                      where Visitor__r.Email = :attendeeContact.email];
            if(myTokenFetch.size()==0) myToken = new VisitorToken__c(Visitor__c  = cons[0].Id);
            else myToken = myTokenFetch[0];
            
            Integer len = 18;
            Blob blobKey = crypto.generateAesKey(128);
            String key = EncodingUtil.convertToHex(blobKey);
            String pwd = key.substring(0,len);
            myToken.GeneratedToken__c = pwd;
            upsert myToken;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('VANEIGENS Attendance - Your new Token');
            mail.setPlainTextBody('We have generated a new Token for you, use it to access your Vaneigens Office Attendances');
            mail.setHtmlBody('We have generated a new Token for you, use it to access your Vaneigens Office Attendances.<br/>'
                             +'Your token is : <b>' +myToken.GeneratedToken__c+'</b>'
                            +'<br/><br/>Kind Regards,'
                            +'<br/>Vaneigens Team.');
            mail.setSaveAsActivity(false);
            mail.setSenderDisplayName('Vaneigens');
            mail.setTargetObjectId(cons[0].Id);
            
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'We have sent a new Key in your mailbox, please use it.'));

            this.authenticated = false;
            this.token = '';
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You don\'t have any attendance, please book your first attendance.'));
        }
        
    }
}
