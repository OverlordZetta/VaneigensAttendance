import { LightningElement, wire, api,track} from 'lwc';
import ATTENDANCEDATE_FIELD from '@salesforce/schema/Day_In_The_Office__c.Attendance_Date__c';
import ATTENDEENAME_FIELD from '@salesforce/schema/Day_In_The_Office__c.AttendeeName__c';
import DAYOFTHEWEEK_FIELD from '@salesforce/schema/Day_In_The_Office__c.Day_of_the_Week__c';
import currentUserId from '@salesforce/user/Id';
import getMyAttendances from '@salesforce/apex/attendanceDataController.getAttendanceData';
import { refreshApex } from '@salesforce/apex';
import { APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/RefreshMessage__c';


export default class AttendanceData extends LightningElement {
    filterValue = 'THIS_WEEK';
    @api columns = [
        {label: 'Attendee', fieldName: ATTENDEENAME_FIELD.fieldApiName},
        {label: 'Week Day', fieldName: DAYOFTHEWEEK_FIELD.fieldApiName},
        {label: 'Attendance Date', fieldName: ATTENDANCEDATE_FIELD.fieldApiName}
    ];
    
    get options() {
        return [
            { label: 'Current Week', value: 'THIS_WEEK' },
            { label: 'Current Month', value: 'THIS_MONTH' }
        ];
    }

    subscription = null;
    
    @wire(MessageContext)
    messageContext;


    @wire(getMyAttendances, { filterValue: '$filterValue', userId : currentUserId})
    attendances;

    

    @api
    get numberOfAttendances() {
        console.log('attendances are : ' + JSON.stringify(this.attendances)); 
        return this.attendances.data ? this.attendances.data.length : ' - ';
    }

    handleChange(event) {
        if(event.target.name==='filterbox') {
            this.filterValue = event.detail.value;
            refreshApex(this.attendances);
            console.log('blaba ' + currentUserId + JSON.stringify(this.attendances));

        }
    }


    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    // Handler for message received by component
    handleMessage(message) {
        refreshApex(this.attendances);
    }
    
    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

}