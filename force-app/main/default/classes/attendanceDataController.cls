public  without sharing class attendanceDataController {

    Public static final String THIS_WEEK = 'THIS_WEEK';
    Public static final String THIS_MONTH = 'THIS_MONTH'; 

    @AuraEnabled(cacheable=true)
    public static List<Day_In_The_Office__c>  getAttendanceData(String filterValue, Id userId){
        if(filterValue==THIS_WEEK) return attendanceData_THIS_WEEK(userId);
        else if(filterValue==THIS_MONTH) return attendanceData_THIS_MONTH(userId);
        else return null;
    }

    public static List<Day_In_The_Office__c> attendanceData_THIS_WEEK(Id userId) {
System.debug('this week)');
        return [Select id,Attendance_Date__c, Attendee__r.Name, AttendeeName__c, Day_of_the_Week__c 
        FROM Day_In_The_Office__c 
        WHERE Attendee__c = :userId
        AND Attendance_Date__c = THIS_WEEK
        ORDER BY Attendance_Date__c DESC];
    }

    public static List<Day_In_The_Office__c>  attendanceData_THIS_MONTH(Id userId) {
        System.debug('this month : ' + [Select id,Attendance_Date__c, Attendee__r.Name, AttendeeName__c, Day_of_the_Week__c 
        FROM Day_In_The_Office__c 
        WHERE Attendee__c = :userId
        AND Attendance_Date__c = THIS_MONTH
        ORDER BY Attendance_Date__c DESC]);

        return [Select id,Attendance_Date__c, Attendee__r.Name, AttendeeName__c, Day_of_the_Week__c 
        FROM Day_In_The_Office__c 
        WHERE Attendee__c = :userId
        AND Attendance_Date__c = THIS_MONTH
        ORDER BY Attendance_Date__c DESC ];
    }
    @AuraEnabled(Cacheable=true)
    public static List<Day_In_The_Office__c> attendanceDate_TomorrowAttendees(){
        return  [Select id,RecordType.DeveloperName, AttendeeName__c, Day_of_the_Week__c 
        FROM Day_In_The_Office__c 
        Where Attendance_Date__c = TOMORROW];

    }
}
