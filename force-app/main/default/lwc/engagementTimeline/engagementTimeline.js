import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getWebRecords from '@salesforce/apex/EngagementTimelineController.getWebRecords';
import getAppRecords from '@salesforce/apex/EngagementTimelineController.getAppRecords';
import getEmailRecords from '@salesforce/apex/EngagementTimelineController.getEmailRecords';




export default class EngagementTimeline extends NavigationMixin(LightningElement) {

    @track webEngagementList ; 
    @track appEngagementList ; 
    @track emailEngagementList ;        

    @track columns = [
        { label: 'Channel', fieldName: 'EngagementChannel__c', type: 'text', sortable: true},
        { label: 'Date Time', fieldName: 'EngagementDateTime__c', type: 'date', sortable: true},
        { label: 'Device', fieldName: 'EngagementDevice__c', type: 'text'},
        { label: 'Event', fieldName: 'EngagementEvent__c', type: 'text'},
    ]; 
    

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

        this.getWebData();
        this.getAppData();
        this.getEmailData();
    }

    // @wire(getEngagementRecords)
    // wiredEngagementList({
    //     error,
    //     data
    // }) {
    //     if (data) {
    //         console.log(data);
    //         this.engagementList = data;
    //     } else if (error) {
    //         this.error = error;
    //     }
    // }

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
    
    getWebData() {
        getWebRecords()
            .then((data) => {
                if (data) {
                    console.log('web : ' + new Date(), JSON.stringify(data));
                    this.webEngagementList = data;
                }
            })
            .catch((error) => {
                    this.error = 'Web Data not available';
                    console.log('Web Error ---> ', error)
            });            
    }
    getAppData() {
        getAppRecords()
            .then((data) => {
                if (data) {
                    console.log('app : ' + new Date(), JSON.stringify(data));
                    this.appEngagementList = data;
                }
            })
            .catch((error) => {
                    this.error = 'App Data not available';
                    console.log('App Error ---> ', error)
            });
    }
    getEmailData() {
        getEmailRecords()
            .then((data) => {
                if (data) {
                    console.log('email : ' + new Date(), JSON.stringify(data));
                    this.emailEngagementList = data;
                }
            })
            .catch((error) => {
                    this.error = 'Email Data not available';
                    console.log('email Error ---> ', error)
            });
    }        

}