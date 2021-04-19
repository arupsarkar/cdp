import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getWebRecords from '@salesforce/apex/EngagementTimelineController.getWebRecords';
import getAppRecords from '@salesforce/apex/EngagementTimelineController.getAppRecords';
import getEmailRecords from '@salesforce/apex/EngagementTimelineController.getEmailRecords';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';



export default class EngagementTimeline extends NavigationMixin(LightningElement) {

    @track webEngagementList ; 
    @track appEngagementList ; 
    @track emailEngagementList ; 
    channelName = '/event/C360_Event__e';
    isSubscribeDisabled = false;
    isUnsubscribeDisabled = !this.isSubscribeDisabled;  
    @track refresh;         

    @track webColumns = [
        { label: 'Date Time', fieldName: 'EngagementDateTime__c', type: 'date', sortable: true},
        { label: 'Domain', fieldName: 'Domain__c', type: 'text', sortable: true},        
        { label: 'Device', fieldName: 'EngagementDevice__c', type: 'text'},
        { label: 'Event', fieldName: 'EngagementEvent__c', type: 'text'},
    ]; 
    @track emailColumns = [
        { label: 'Date Time', fieldName: 'EngagementDateTime__c', type: 'date', sortable: true},        
        { label: 'Subject', fieldName: 'SubjectLine__c', type: 'date', sortable: true},
        { label: 'Event', fieldName: 'EngagementEvent__c', type: 'text'},
    ]; 
    @track appColumns = [
        { label: 'Date Time', fieldName: 'EngagementDateTime__c', type: 'date', sortable: true},
        { label: 'Device OS', fieldName: 'Device_OS_Name__c', type: 'date', sortable: true},
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

        this.refresh = false;
        this.getWebData();
        this.getAppData();
        this.getEmailData();
        this.handleSubscribe();            
        // Register error listener       
        this.registerErrorListener();         
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
    
    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback =  (response) => {
            console.log('Engagement PE fired : ', JSON.stringify(response));
            // Response contains the payload of the new message received
            this.notifier = JSON.stringify(response);
            // refresh LWC
            if(response.data.payload.Category__c == 'Engagement') {
                this.getWebData();
                this.getAppData();
                this.getEmailData();
                this.refresh = true;
            }
            


        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
            this.toggleSubscribeButton(true);
        });
    }

    toggleSubscribeButton(enableSubscribe) {
        this.isSubscribeDisabled = enableSubscribe;
        this.isUnsubscribeDisabled = !enableSubscribe;
    }
        
    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }    

}