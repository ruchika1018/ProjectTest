({
    doInit : function (component, event, helper) {
        var names = component.get('v.touchPoint');
        //console.log('Rest ' + names);
        if(names == undefined || names == ''){
            
        }else{
           var nameArr = names.split(',');
            console.log('test array ' + nameArr); 
            component.set('v.value', nameArr); 
        }
        
    	var action = component.get("c.getTouchpoints");
		 action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Retunr' + response.getReturnValue());
                var returnValue = response.getReturnValue();
                var options = [];
                for (var i in returnValue) {
                    console.log('Test call');
                    var rec = { 
                        'label' : returnValue[i].Touchpoint_Name__c, 
                        'value' :  returnValue[i].Touchpoint_Name__c
                    };
                    console.log('Rec ' + rec);
                    options.push(rec);
                }
                component.set('v.options', options);
                console.log('Options ' + options);
            }
         });
        $A.enqueueAction(action);
    }, 
                            
    handleChange: function (component, event, helper) {
       // alert(event.getParam('value'));
        helper.fireComponentEvent(component, event, event.getParam('value'));
    }
})