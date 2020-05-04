({
	fetchNPAData : function(component, event, helper) {       
        
        //===================GET DATA FROM SERVER=================
        debugger;
        var action = component.get('c.getNPADetails');          
        action.setCallback(this, function(a) {
            var state = a.getState(); 
            if (state == 'SUCCESS') { 
                
                var responseWrapper = {};
                responseWrapper = JSON.parse(a.getReturnValue());                
                
                //Set Caller Name
                component.set('v.secondCallerName', responseWrapper.secondCallerName);                
                //Set NPS Data
                this.setNPAListTableData(component, event, helper,responseWrapper);
                this.setTargetTableData(component, event, helper,responseWrapper);
            }
        });
        $A.enqueueAction(action);
	},
    setNPAListTableData : function(component, event, helper, responseWrapper) {
        debugger;
        var npsTableColumnLabels 	= responseWrapper.npsTableColumnLabels;
        var npsDataReceived  		= responseWrapper.npsData;
        var npsTableName 			= responseWrapper.npsTableName;
        var isNPAAnalystLoggedIn    = responseWrapper.isNpaAnalystLoggedIn;
       	component.set("v.npsTableName", 	 npsTableName);
        var npaColumnNames = [	
                    {  fieldName:"URL"
                     , label:""+responseWrapper.npsTableColumnLabels[9]
                     , sortable:true 
                     , type:'url'
                     , clipText : true
                     , typeAttributes: {label: { fieldName: 'customerId' }, target: '_blank',wraptext:false,cliptext:false}
                    }
            		 , { 
                            fieldName:"customerName"
                          , label:""+responseWrapper.npsTableColumnLabels[0]
                          , sortable:true
                          , wrapText : true
                        }            
                     , { 
                            fieldName:"customertouchpoint"
                          , label:""+responseWrapper.npsTableColumnLabels[8]
                          , sortable:true
                          , wrapText : true
                        }
                     , { fieldName:"npsStatus", label:""+responseWrapper.npsTableColumnLabels[1], 	sortable:true, initialWidth: 110 , wrapText : true}
                     , { fieldName:"npsRating", label:""+responseWrapper.npsTableColumnLabels[2], 	type: 'number',sortable:true, initialWidth: 70 }
                     , { fieldName:"daysSinceSCAssignment", label:""+responseWrapper.npsTableColumnLabels[3],type: 'number', 	sortable:true, initialWidth: 160 }
            		 , { fieldName:"callbackdate"
                        , label:""+responseWrapper.npsTableColumnLabels[4]
                        , type: 'date'
                        , sortable:true
                        , wrapText : true
                        , initialWidth: 175
                        , typeAttributes: {  
                            day: 'numeric',  
                            month: 'numeric',  
                            year: 'numeric',  
                            hour: '2-digit',  
                            minute: '2-digit',  
                            second: '2-digit',  
                            hour12: true}
                       }
            		 , { fieldName:"isReassigned", label:""+responseWrapper.npsTableColumnLabels[5], 	sortable:true, initialWidth: 120, wrapText : true }
       				 , { fieldName:"lastModifiedDate"
                        , label:""+responseWrapper.npsTableColumnLabels[7]
                        , 	type: 'date'
                        , sortable:true
                        , wrapText : true
                        , initialWidth: 175
                        , typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'numeric',  
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',  
                                                                            minute: '2-digit',  
                                                                            second: '2-digit',  
                                                                            hour12: true}
                       }
        ]; 
        if (isNPAAnalystLoggedIn) {

            var ownerNameColumn = [
              	{ 
                    fieldName:"ownerName"
                  , label:""+responseWrapper.npsTableColumnLabels[6]
                  , sortable:true
                  , wrapText : true
                }

            ];            
           
            npaColumnNames.push(ownerNameColumn[0]);
            
       }
       	component.set("v.npsColumns", 	 npaColumnNames);
       //-------------------------------------------------------------
       //Set Customer Data
        var npsDetails = [];
        var npsInfo = {};
        
       for (var i in npsDataReceived ) {
            npsInfo = {};
           debugger;
            var customerId 		= npsDataReceived[i]['Customer__r'] != undefined && npsDataReceived[i]['Customer__r'] != null 
            						? npsDataReceived[i]['Customer__r'].Name 
            						: '';
            
            npsInfo['customerId'] = customerId != null && customerId != undefined ? customerId :'';   
           
            var customerName 		= npsDataReceived[i]['Customer__r'] != undefined && npsDataReceived[i]['Customer__r'] != null 
            						? npsDataReceived[i]['Customer__r'].Customer_Name__c 
            						: '';
            
            npsInfo['customerName'] = customerName != null && customerName != undefined ? customerName :'';   
           
               
            npsInfo['customertouchpoint']		= npsDataReceived[i]['Customer__r'] != undefined && npsDataReceived[i]['Customer__r'] != null 
                                                    ? npsDataReceived[i]['Customer__r'].RecordType.Name
                                                    : '';            
           
            npsInfo['npsStatus'] 	= npsDataReceived[i].Status__c != undefined && npsDataReceived[i].Status__c != null
                                        ? '' +  npsDataReceived[i].Status__c 
                                        : '-';
            npsInfo['npsRating']   	= npsDataReceived[i].NPA_Rating__c != undefined && npsDataReceived[i].NPA_Rating__c != null
                                                ? ''+npsDataReceived[i].NPA_Rating__c
                                                : '-';            
            npsInfo['URL'] 			= '/lightning/r/Net_Promoter_Score__c/' + npsDataReceived[i].Id + '/view';
           
            npsInfo['daysSinceSCAssignment'] = npsDataReceived[i].Days_since_SC_Assignment__c != undefined && npsDataReceived[i].Days_since_SC_Assignment__c != null
            								 ? npsDataReceived[i].Days_since_SC_Assignment__c
            								 : null;
           var isStatusClosed = npsDataReceived[i].Status__c == 'Closed'?true:false;
           var callbackdate =isStatusClosed == true ? '-':this.setCallBackDate(npsDataReceived[i]);
           npsInfo['callbackdate']	= ''+callbackdate;
                
           npsInfo['isReassigned']  =    npsDataReceived[i].Is_SC_Reassigned__c == true ? 'Yes' : 'No';  
           
           if (isNPAAnalystLoggedIn) {
                npsInfo['ownerName']		= npsDataReceived[i]['Customer__r'] != undefined && npsDataReceived[i]['Customer__r'] != null 
                                            ? npsDataReceived[i]['Customer__r'].Owner.Name 
                                            : '';
           }   
           
           npsInfo['lastModifiedDate']	 = npsDataReceived[i].LastModifiedDate != undefined && npsDataReceived[i].LastModifiedDate != null
            								 ? ''+npsDataReceived[i].LastModifiedDate
            								 : '';
           
           npsDetails.push(npsInfo);  
        }
        
        component.set('v.npsData', npsDetails);
        this.addClosedToEndOfTheList(component);
    },
    
    setCallBackDate : function(nps) {
        debugger;
        var callbackdate = null;
        if (nps.Is_SC_Reassigned__c != null && nps.Is_SC_Reassigned__c != undefined && nps.Is_SC_Reassigned__c == true) {                    
            if (   (nps.Rsc3_Callback_Date__c == null || nps.Rsc3_Callback_Date__c == undefined) 
                && (nps.Rsc2_Callback_Date__c == null || nps.Rsc2_Callback_Date__c == undefined) 
                && (nps.Rsc1_Callback_Date__c == null || nps.Rsc1_Callback_Date__c == undefined)
               ) {
                callbackdate = null;
            } else {
                if ( nps.Rsc3_Callback_Date__c ) {
                    callbackdate = nps.Rsc3_Callback_Date__c;                     
                } else if ( nps.Rsc2_Callback_Date__c ) {
                    callbackdate = nps.Rsc2_Callback_Date__c;                      
                } else if ( nps.Rsc1_Callback_Date__c ) {
                    callbackdate = nps.Rsc1_Callback_Date__c;                    
                }
            }                    
        } else {
            if (   (nps.Sc3_Callback_Date__c == null || nps.Sc3_Callback_Date__c == undefined)
                && (nps.Sc2_Callback_Date__c == null || nps.Sc2_Callback_Date__c == undefined) 
                && (nps.Sc1_Callback_Date__c == null || nps.Sc1_Callback_Date__c == undefined)
               ) {
               callbackdate = null;
            } else {
                if ( nps.Sc3_Callback_Date__c ) {
                          callbackdate = nps.Sc3_Callback_Date__c;                
                } else if ( nps.Sc2_Callback_Date__c ) {
                          callbackdate = nps.Sc2_Callback_Date__c;                
                } else if ( nps.Sc1_Callback_Date__c ) {
                          callbackdate = nps.Sc1_Callback_Date__c;                
                }
            } 
        }            
        return callbackdate;
    },
    
    setTargetTableData : function(component, event, helper, responseWrapper) {
         var targetColumnNames = [	
                    { fieldName:"achieved", label:"Achieved", 	sortable:true }
         ];
         component.set('v.targetColumnNames', targetColumnNames);
        var targetCount = responseWrapper.targetCount !=null && responseWrapper.targetCount != undefined
        				? ''+responseWrapper.targetCount
        				: ''+0;
        
        var targetDetails = [];  
        var targetInfo = {};
        targetInfo['achieved'] = ''+targetCount;
        targetDetails.push(targetInfo)
        component.set('v.targetsData', targetDetails);        
        debugger;
    },
    
     sortBy: function (field, reverse, primer) {
         debugger;
        var key = primer ?
            function(x) { return primer(x[field]) } :
        function(x) { return x[field] };
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            debugger;
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.npsData"); 
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.npsData", data);
    },
    addClosedToEndOfTheList : function (cmp) {
        debugger;
        var npsData = cmp.get("v.npsData");
        var closedCustomers = [];
        var data = [];
        for (var i in npsData ) {
            if (npsData[i].npsStatus && npsData[i].npsStatus == 'Closed') {
                closedCustomers.push(npsData[i]);
            } else {
                data.push(npsData[i]);
            }
        }
       
        for (var i in closedCustomers) {
             data.push(closedCustomers[i]);
        } 
        
        cmp.set("v.npsData", data);
    }
})