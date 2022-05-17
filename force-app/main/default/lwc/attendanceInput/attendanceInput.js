import { LightningElement, api,wire } from 'lwc';
import saveAttendance from '@salesforce/apex/VisitorAttendanceInput_Controller.saveAttendance';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


// Import message service features required for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/RefreshMessage__c';

export default class AttendanceInput extends LightningElement {
    
    @api firstName;
    @api lastName;
    @api email;
    @api attendanceDate;
    
    error;
    
    
    @wire(MessageContext)
    messageContext;
    
    handleChange(event){
        if(event.target.name==='firstName') this.firstName = event.target.value;
        if(event.target.name==='lastName') this.lastName = event.target.value;
        if(event.target.name==='attendanceDate') this.attendanceDate = event.target.value;
        if(event.target.name==='email') this.email = event.target.value;
    }
    
    handleSave() {
        if(this.isInputValid()) {
            console.log('params sendin are : ' + this.lastName);
            saveAttendance({ firstName: this.firstName, lastName : this.lastName, email : this.email, attendanceDate : this.attendanceDate })
            .then((result) => {
                this.displayToast('Success!','You have successfully booked an attendance!','success');
                this.emptyFields();
                const payload = {data:"some data juste in case"};
                publish(this.messageContext, recordSelected,payload);
            })
            .catch((error) => {
                console.log('this is error' + JSON.stringify(error));
                this.error = error;
                this.displayToast('Error creating record',error.body.pageErrors[0].message,'error');
            });
        }
    }
    
    emptyFields(){
        this.template.querySelectorAll('.validate').forEach(element => {
            element.value = null;
        });
    }
    
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    
    //Utility method to display toasts
    displayToast(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
            );   
        }
        
    }