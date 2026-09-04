({
    init: function(comp, event, helper){
        console.log('init');
        helper.doInit(comp);
    },
    handleConfirm: function( comp ) {
        const navigation = comp.find('navigation'),
            recordId = comp.get('v.applicationId');
        console.log({ recordId });

        navigation.navigate({
                type: 'standard__recordPage',
                attributes: {
                    recordId,
                    actionName: 'view'
                }
            });

    }
})