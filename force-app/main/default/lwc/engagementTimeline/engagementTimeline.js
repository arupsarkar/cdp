import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getEngagementRecords from '@salesforce/apex/EngagementTimelineController.getEngagementRecords';

export default class EngagementTimeline extends NavigationMixin(LightningElement) {

    @track engagementList ;    

    connectedCallback() {
        this.engagementPageRef = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'C360_Engagement_Timeline__c',
                actionName: 'home'
            }
        };
        this[NavigationMixin.GenerateUrl](this.engagementPageRef)
            .then(url => this.url = url);
    }

    @wire(getEngagementRecords)
    wiredEngagementList({
        error,
        data
    }) {
        if (data) {
            console.log(data);
            this.engagementList = data;
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
        this[NavigationMixin.Navigate](this.engagementPageRef);
    }  
    
    handleNavigateByDataAttribute(event){
        //getting record id using using data-attributes
        const selectedRecordId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecordId,
                objectApiName: 'C360_Engagement_Timeline__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }    

}