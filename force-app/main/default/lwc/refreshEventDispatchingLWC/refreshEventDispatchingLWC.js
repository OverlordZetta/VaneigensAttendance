import { LightningElement,wire } from 'lwc';
// Import message service features required for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/RefreshMessage__c';

export default class RefreshEventDispatchingLWC extends LightningElement {


    @wire(MessageContext)
    messageContext;




    
    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    connectedCallback() {
        console.log('dispatching message');
        const payload = {data:"some data juste in case"};
        publish(this.messageContext, recordSelected,payload);
    }
}