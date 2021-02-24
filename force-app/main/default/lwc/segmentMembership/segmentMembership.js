import { LightningElement ,wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getSegmentMemberships from '@salesforce/apex/SegmentMembershipController.getSegmentMemberships';

export default class SegmentMembership extends NavigationMixin(LightningElement) {

    @track columns = [{
        label: 'Product',
        fieldName: 'Segment_Name__c',
        type: 'text'
    }];
    @track segmentName;
    @track segmentMembershipList ;
    url;

    connectedCallback() {
        this.recentSegmentMembershipPageRef = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'C360_Segment_Membership__c',
                actionName: 'home'
            }
        };
        this[NavigationMixin.GenerateUrl](this.recentSegmentMembershipPageRef)
            .then(url => this.url = url);        
    }

    @wire(getSegmentMemberships)
    wiredSegmentMembershipList({
        error,
        data
    }) {
        if (data) {
            console.log(data);
            this.segmentName = data[0].Segment_Name__c;
            this.segmentMembershipList = data;
        } else if (error) {
            this.error = error;
        }
    } 
    
    handleClick(evt) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        evt.preventDefault();
        evt.stopPropagation();
        // Navigate to the Account Home page.
        this[NavigationMixin.Navigate](this.recentSegmentMembershipPageRef);
    }      
}