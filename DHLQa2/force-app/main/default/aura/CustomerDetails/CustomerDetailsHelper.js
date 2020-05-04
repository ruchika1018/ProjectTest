({
	fetchCustomerDataHelper : function(component, event, helper) {       
        
        //===================GET DATA FROM SERVER=================
        
        var action = component.get('c.getCustomerDetails');          
        action.setCallback(this, function(a) {
            var state = a.getState(); 
            if (state == 'SUCCESS') { 
                
                var responseWrapper = {};
                responseWrapper = JSON.parse(a.getReturnValue());                
                
                //Set Caller Name
                component.set('v.firstCallerName', responseWrapper.firstCallerName);                
                //Set Customer Data
                this.setCustomerListTableData(component, event, helper,responseWrapper);
                this.setTargetTableData(component, event, helper,responseWrapper);
            }
        });
        $A.enqueueAction(action);
	},
    
    setCustomerListTableData : function(component, event, helper, responseWrapper) {      
        var customerTableColumnLabels 	= responseWrapper.customerTableColumnLabels;
        var customerDataReceived  		= responseWrapper.customerData;
        var customerIdStatusMap   		= responseWrapper.customerIdStatusMap;
        var customerIdRatingMap   		= responseWrapper.customerIdRatingMap;
        var callNotAttemptedLabel       = responseWrapper.callNotAttemptedLabel;
        var customerIdCallAttemptsMap   = responseWrapper.customerIdCallAttemptsMap;
        var customerIdNPSRecordMap      = responseWrapper.customerIdNPSRecordMap;
        var isNpaAnalystLoggedIn        = responseWrapper.isNpaAnalystLoggedIn;
        
        var customerNameColumn = [];
        
        if (isNpaAnalystLoggedIn) {
            var custNameWithoutURL = [
                { fieldName:"customerId"
                 , label:""+responseWrapper.customerTableColumnLabels[8]
                 , sortable:true
                 , clipText : true
                 , initialWidth: 150
                }
            ];
            
            var isSharedColumn = [
                 { 
                   fieldName:"isShared"
                 , label:"Is Shared"
                 , sortable:true
                 , initialWidth: 120
                }
            ]
            customerNameColumn.push(custNameWithoutURL[0]);
            customerNameColumn.push(isSharedColumn[0]);
        } else {
             var custNameWithURL = [
                 {  fieldName:"URL"
                     , label:""+responseWrapper.customerTableColumnLabels[8]
                     , sortable:true 
                     , type:'url'  
                  	 , clipText : true
                     , typeAttributes: {label: { fieldName: 'customerId' }, target: '_self',wraptext:false,cliptext:false}
                  	 , initialWidth: 150
                    }
              ];
             customerNameColumn.push(custNameWithURL[0]);
        }
        var customerColumnNames = [	   
            		   { fieldName:"customerName", label:""+responseWrapper.customerTableColumnLabels[0], 	sortable:true, initialWidth: 200}
                     , { fieldName:"customertouchpoint", label:""+responseWrapper.customerTableColumnLabels[1], 	sortable:true, initialWidth: 150}
            		 , { fieldName:"callStatus", 		 label:""+responseWrapper.customerTableColumnLabels[2], 	sortable:true,initialWidth: 150 }
                     , { fieldName:"callAttempts", 		 label:""+responseWrapper.customerTableColumnLabels[3], 	sortable:true, initialWidth: 140 }
            		 , { fieldName:"rating",	 		 label:""+responseWrapper.customerTableColumnLabels[4], 	sortable:true, initialWidth: 100 }
            		 , { fieldName:"callBackDate"
                        , label:""+responseWrapper.customerTableColumnLabels[5]
                        , type: 'date'
                        , sortable:true
                        , initialWidth: 180
                        , typeAttributes: {  
                                            day: 'numeric',  
                                            month: 'short',  
                                            year: 'numeric',  
                                            hour: '2-digit',  
                                            minute: '2-digit',  
                                            second: '2-digit',  
                                            hour12: true
                        				}
                       }
            		 , { fieldName:"lastModifiedDate"
                        , label:""+responseWrapper.customerTableColumnLabels[7]
                        , type: 'date'
                        , sortable:true                        
                        , typeAttributes: {  
                                            day: 'numeric',  
                                            month: 'numeric',  
                                            year: 'numeric',  
                                            hour: '2-digit',  
                                            minute: '2-digit',  
                                            second: '2-digit',  
                                            hour12: true
                        				}
                       }

        ]; 
      
        customerColumnNames.splice(0,0,customerNameColumn[0]);//Adding customer name column
        if (isNpaAnalystLoggedIn) {
            customerColumnNames.splice(2,0,customerNameColumn[1]);//Adding isShared column
            component.set("v.renderTargetTable",false);
            var ownerNameColumn = [
              	{ 
                    fieldName:"ownerName"
                  , label:""+responseWrapper.customerTableColumnLabels[6]
                  , sortable:true
                  , wrapText : true
                }

            ];
            customerColumnNames.push(ownerNameColumn[0]);
        } else {
             component.set("v.renderTargetTable",true);
        }
       	component.set("v.customerColumns", 	 customerColumnNames);
       //-------------------------------------------------------------
       //Set Customer Data
        var customerDetails = [];
        var customerInfo = {
              customerId 			: ''
            , customerName			: ''
            , customertouchpoint	: ''
            , callAttempts 			: ''
            , callStatus    		: ''
            , rating                : ''
            , callBackDate			: ''
        };
       
        customerDataReceived = this.getValidRecords(customerDataReceived,customerIdNPSRecordMap);
        for (var i in customerDataReceived ) {
            customerInfo = {};
            
            customerInfo['customerId']  = customerDataReceived[i].Name != undefined && customerDataReceived[i].Name != null
                                        ? customerDataReceived[i].Name
                                        : '';
            customerInfo['customerName'] = customerDataReceived[i].Customer_Name__c != undefined && customerDataReceived[i].Customer_Name__c != null
                                        ? customerDataReceived[i].Customer_Name__c
                                        : '';
            var custRecordType = 	   customerDataReceived[i].RecordType != undefined
            						&& customerDataReceived[i].RecordType != null
                                    ? customerDataReceived[i].RecordType.Name
                                    : '';
            customerInfo['customertouchpoint']   = custRecordType != undefined && custRecordType != null && custRecordType != ''
                                                ? customerDataReceived[i].RecordType.Name
                                                : '';
            
            var Id = customerDataReceived[i].Id;
          
           var rating = customerIdRatingMap[customerDataReceived[i].Id];
           var ratingValue = rating != null  || rating != undefined 
                           ? ''+rating
                           : '-';
           customerInfo['rating']   	= ratingValue;
           var statusReceived = customerIdStatusMap[customerDataReceived[i].Id];
           var status = ratingValue != '' && ratingValue != undefined && ratingValue != null &&  ratingValue != '-'
           				  ? 'Closed'
               			  :statusReceived;
           customerInfo['callStatus']  	=  status!= null || status!= undefined
           								? ''+status
           								: '-';
            
           customerInfo['URL'] 			= '/lightning/r/Customer__c/' + customerDataReceived[i].Id + '/view';
          
            
          
           var callAttempt = customerIdCallAttemptsMap[customerDataReceived[i].Id];
           customerInfo['callAttempts'] = callAttempt != undefined && callAttempt != null
                                        ? '' + callAttempt
                                        : '-'; 
          
           var nps = customerIdNPSRecordMap[customerDataReceived[i].Id];
           customerInfo['callBackDate'] = nps != null && nps != undefined 
               							? ''+this.setCallBackDate(nps)
           								: '';
            
            
            
           customerInfo['lastModifiedDate']	= customerDataReceived[i].LastModifiedDate != undefined && customerDataReceived[i].LastModifiedDate != null 
                                                    ? ''+customerDataReceived[i].LastModifiedDate
                                                    : '';  
            if (isNpaAnalystLoggedIn) {
                customerInfo['isShared'] = customerDataReceived[i].Is_Shared__c != null && customerDataReceived[i].Is_Shared__c != undefined 
                                        ? customerDataReceived[i].Is_Shared__c == true? 'Yes' : 'No'
                                        : '-';
                
                
           		customerInfo['ownerName']	= customerDataReceived[i].Owner.Name != undefined && customerDataReceived[i].Owner.Name != null 
                                            ? ''+customerDataReceived[i].Owner.Name
                                            : '';
            }
          
           customerDetails.push(customerInfo);
          
        }               
        
        component.set('v.customerData', customerDetails);
        
        this.addClosedToEndOfTheList(component);
        
    },
    
    setTargetTableData : function(component, event, helper, responseWrapper) {
        var targetDataReceived	  		= responseWrapper.targetData;                
        var targetKeyNonkeyLabels 		= responseWrapper.targetTableKeyNonkeyLabels;
        var targetTableColumnLabels 	= responseWrapper.targetTableColumnLabels;
                           
        //-----------------------------------------------                
        //Set Targets Data Table Data               
        
        var targetColumnNames = [
            { fieldName:"count", 	 		label:"", 	 	 	 						 sortable:false, fixedWidth : 180}
            , { fieldName:"CE", 	 		label:""+targetTableColumnLabels[0], 		 sortable:false}
            , { fieldName:"Operations",     label:""+targetTableColumnLabels[1], 		 sortable:false}
            , { fieldName:"OM", 			label:""+targetTableColumnLabels[2], 	  	 sortable:false}
            , { fieldName:"Sales", 			label:""+targetTableColumnLabels[3], 	  	 sortable:false}
            , { fieldName:"Billing", 		label:""+targetTableColumnLabels[4], 	  	 sortable:false}
           
        ]; 
        
        component.set("v.targetColumnNames", targetColumnNames);
        
        var targetDataWrapper = {
            key  : {
                count      : ''
                , CE 	 	 : 0                    
                , Operations : 0
                , OM 	 	 : 0
                , Sales		 : 0
                , Billing    : 0
            },
            nonKey :  {
                count      : ''
                , CE 	 	 : 0                    
                , Operations : 0
                , OM 	 	 : 0
                , Sales		 : 0
                , Billing    : 0
            }
        }
        
               var targetDetails = [];
                var CEKey =0,CENonKey=0,OperationsKey=0,OperationsnonKey=0,OMKey=0,OMnonKey=0,salesKey=0,salesnonKey=0,billingKey=0,billingnonKey=0;
               
               for (var i in targetDataReceived ) {                   
                    targetDataWrapper = {};
                   if (targetDataReceived[i].touchpoint != null && targetDataReceived[i].touchpoint != undefined) {
                    	if(targetDataReceived[i].touchpoint == 'Customer Excellence') {                       
                            CEKey = targetDataReceived[i].keyAccounts ;
                            CENonKey = targetDataReceived[i].nonKeyAccounts;
                        }  else if(targetDataReceived[i].touchpoint == 'Operations') {
                        	OperationsKey = targetDataReceived[i].keyAccounts ;
                            OperationsnonKey = targetDataReceived[i].nonKeyAccounts;
                        } else if(targetDataReceived[i].touchpoint == 'Order Management') {
                                 OMKey = targetDataReceived[i].keyAccounts ;
                                OMnonKey = targetDataReceived[i].nonKeyAccounts;
                        } else if(targetDataReceived[i].touchpoint == 'Sales') {
                                 salesKey = targetDataReceived[i].keyAccounts ;
                                salesnonKey = targetDataReceived[i].nonKeyAccounts;
                        } else if(targetDataReceived[i].touchpoint == 'Billing') {
                               billingKey   = targetDataReceived[i].keyAccounts ;
                               billingnonKey = targetDataReceived[i].nonKeyAccounts;
                        }
                       								
                    }                                                         
                }
                targetDataWrapper.key 			= {};
                targetDataWrapper.key.count		= targetKeyNonkeyLabels[0];
                targetDataWrapper.key.CE		= ''+CEKey;
                targetDataWrapper.key.Operations= ''+OperationsKey;
                targetDataWrapper.key.OM 		= ''+OMKey;
                targetDataWrapper.key.Sales		= ''+salesKey ;
        		targetDataWrapper.key.Billing   = ''+billingKey;
                targetDetails.push(targetDataWrapper.key); 
                
                targetDataWrapper.nonKey = {};
                targetDataWrapper.nonKey.count			= targetKeyNonkeyLabels[1];
                targetDataWrapper.nonKey.CE 			= ''+CENonKey;
                targetDataWrapper.nonKey.Operations		=''+OperationsnonKey;
                targetDataWrapper.nonKey.OM 			=''+OMnonKey;
                targetDataWrapper.nonKey.Sales			=''+salesnonKey;
        		targetDataWrapper.nonKey.Billing   		= ''+billingnonKey
                targetDetails.push(targetDataWrapper.nonKey); 
				component.set('v.targetsData', targetDetails);
    },    
    
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.customerData"); 
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.customerData", data);
    },
    
    addClosedToEndOfTheList : function (cmp) {
        var custData = cmp.get("v.customerData");
        var closedCustomers = [];
        var data = [];
        for (var i in custData ) {
            if (custData[i].callStatus && custData[i].callStatus == 'Closed') {
                closedCustomers.push(custData[i]);
            } else {
                data.push(custData[i]);
            }
        }
       
        for (var i in closedCustomers) {
             data.push(closedCustomers[i]);
        } 
        
        cmp.set("v.customerData", data);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) { return primer(x[field]) } :
        function(x) { return x[field] };
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    setCallBackDate : function(nps) {      
        var callbackdate = '';        
            if (   (nps.Fc3_Callback_Date__c == null || nps.Fc3_Callback_Date__c == undefined)
                && (nps.Fc2_Callback_Date__c == null || nps.Fc2_Callback_Date__c == undefined) 
                && (nps.Fc1_Callback_Date__c == null || nps.Fc1_Callback_Date__c == undefined)
               ) {
              return callbackdate;
            } else {
                if ( nps.Fc3_Callback_Date__c ) {
                          callbackdate = ''+nps.Fc3_Callback_Date__c;                
                } else if ( nps.Fc2_Callback_Date__c ) {
                          callbackdate = ''+nps.Fc2_Callback_Date__c;                
                } else if ( nps.Fc1_Callback_Date__c ) {
                          callbackdate = ''+nps.Fc1_Callback_Date__c;                
                }
            } 
                
        return callbackdate;
    },
    getValidRecords : function(customerDataReceived,customerIdNPSRecordMap) {
        var customerRecordsToDisplay = [];
        debugger;
        for (var i in customerDataReceived) {
			var nps = customerIdNPSRecordMap[customerDataReceived[i].Id];
            if (nps) {
                if (nps.NPA_Rating__c && nps.NPA_Rating__c < 9) {
                     customerRecordsToDisplay.push(customerDataReceived[i]);
                } else if (nps.NPA_Rating__c == undefined || nps.NPA_Rating__c == null || nps.NPA_Rating__c == '' ) {
                    customerRecordsToDisplay.push(customerDataReceived[i]);
                }
            } else {
                customerRecordsToDisplay.push(customerDataReceived[i]);
            }
        }
        return customerRecordsToDisplay;        
    }
})