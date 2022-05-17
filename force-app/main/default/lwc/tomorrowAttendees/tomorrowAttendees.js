import { LightningElement, wire, api,track} from 'lwc';
import getTomorrowAttendees from '@salesforce/apex/attendanceDataController.attendanceDate_TomorrowAttendees';
import { refreshApex } from '@salesforce/apex';


import { APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe} from 'lightning/messageService';
    import recordSelected from '@salesforce/messageChannel/RefreshMessage__c';
    
    
    
    const RT_Visitor = 'Visitor_Attendance';
    const RT_Employee = 'Employee_Attendance';
    
    export default class TomorrowAttendees extends LightningElement {
        
        subscription = null;
        
        @wire(MessageContext)
        messageContext;
        
        isThereSomeone=false;
        _wiredAttendees;
        @track attendeesVisitor;
        @track attendeesEmployees;
        @track errorTomorrowAttendees;
        @wire(getTomorrowAttendees)
        
        fetchTomorrowAttendees(result){
            this._wiredAttendances = result;
            const { data, error } = result;
            if(data) { 
                if(data.length>0) this.isThereSomeone = true;
                console.log('data : ' + JSON.stringify(data));
                let visitors = data.filter(row => row.RecordType.DeveloperName === RT_Visitor );
                if(visitors.length>0) this.attendeesVisitor = visitors.map(row => {
                    return {
                        ...row,
                        redirectUrl: '/' + row.Id 
                    }
                });
                else this.attendeesVisitor = null;
                
                let employees = data.filter(row => row.RecordType.DeveloperName === RT_Employee );
                if(employees.length>0) this.attendeesEmployees = employees.map(row => {
                    return {
                        ...row,
                        redirectUrl: '/' + row.Id 
                    }
                });
                else this.attendeesEmployees = null;
                console.log('data employ : ' + JSON.stringify(this.attendeesEmployees));
                
            }
            else if(error) {
                this.errorTomorrowAttendees = error;
                this.attendeesVisitor ;
                this.attendeesEmployees;
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
                console.log('received event');
                refreshApex(this._wiredAttendances);
            }
            
            // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
            connectedCallback() {
                console.log('subscribing');
                this.subscribeToMessageChannel();
            }
            
            disconnectedCallback() {
                this.unsubscribeToMessageChannel();
            }
            
        }