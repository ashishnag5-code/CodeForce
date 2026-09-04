/*****
 * Class Name: PricingApprovalHandler
 * Description: 
 * Test Class Name: LosPricingApprovalTest and PricingApprovalEventTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-14-2023          -   Mohit M.            -   SFAU-5722 - pricing approvals not created in preapproved cases
 */
public without sharing class PricingApprovalHandler {
    public static Boolean isFirstPass = false;
      public static void insertPricingApprovalPlatformEvent(Map<Id, sObject> updatedApplications,Map<Id, sObject> oldApplications){
         //Added by naga for 101 SOQL issue.
         //Commented FirstPass check as Pricing Approvals were not getting triggered for STP cases
          //if(!isFirstPass){
          system.debug('inside insertPricingApprovalPlatformEvent');
          Map<Id, Loan_Application__c> loanApplications = (Map<Id, Loan_Application__c>) updatedApplications;
          Map<Id, Loan_Application__c> oldLoanApplications = (Map<Id, Loan_Application__c>) oldApplications;
          List<Pricing_Approval_Event__e> eventsToPublish = new List<Pricing_Approval_Event__e>();
          Map<Id,List<Loan_Application_Approval__c>> reinitiatePricingloanApps = new Map<Id, List<Loan_Application_Approval__c>>();
          Map<Id,List<Loan_Application_Approval__c>> clonePricingForSendBackloanApps = new Map<Id, List<Loan_Application_Approval__c>>();

          for(Loan_Application__c loan: loanApplications.values()){
              // SFAU-5722 - Add Pre Approved Flag
              if(loan.No_Pricing_Deviation__c==false && (loan.Bre_Decision__c==GlobalConstants.BRE_DECISION_STP || loan.Pre_Approved_Flag__c)){
                  if(loan.Stage__c==GlobalConstants.STAGE_PRICING && oldLoanApplications.get(loan.Id).Stage__c!=GlobalConstants.STAGE_PRICING){
                      Pricing_Approval_Event__e pricingEvent = new Pricing_Approval_Event__e();
                      pricingEvent.sObjectId__c = loan.Id;
                      eventsToPublish.add(pricingEvent);
                  }
              }
              // SFAU-5722 - Add Pre Approved Flag
              else if(loan.No_Pricing_Deviation__c==false && (loan.Bre_Decision__c==GlobalConstants.BRE_DECISION_NSTP || loan.Pre_Approved_Flag__c)){//SFAU-5226 AND SFAU-5350
                      // CUG -- Added ( Is_Being_Relooked__c ) Case gets stuck on Pricing when it was relooked
                      // SFAU-5083 - 11/08/23 | When BRE Re runs at Credit stage, Credit reassignment has to be done based on BRE Approval Level received from BRE
                  if(loan.Stage__c==GlobalConstants.STAGE_CREDIT && (oldLoanApplications.get(loan.Id).Stage__c!=GlobalConstants.STAGE_CREDIT || (loan.Is_Being_Relooked__c/* && !oldLoanApplications.get(loan.Id).Is_Being_Relooked__c*/) || (oldLoanApplications.get(loan.Id).Stage__c == GlobalConstants.STAGE_CREDIT && loan.BRE_Approval_Level__c != oldLoanApplications.get(loan.Id).BRE_Approval_Level__c))){
                      Pricing_Approval_Event__e pricingEvent = new Pricing_Approval_Event__e();
                      pricingEvent.sObjectId__c = loan.Id;
                      eventsToPublish.add(pricingEvent);
                  }else if(loan.Stage__c==GlobalConstants.STAGE_PRICING && oldLoanApplications.get(loan.Id).Stage__c!=GlobalConstants.STAGE_PRICING){
                      reinitiatePricingloanApps.put(loan.Id,new List<Loan_Application_Approval__c>());
                        if(loan.Send_Back_To_RO_Stage__c==null && oldLoanApplications.get(loan.Id).Send_Back_To_RO_Stage__c=='Pricing'){
                        clonePricingForSendBackloanApps.put(loan.Id,new List<Loan_Application_Approval__c>());
                    }
                  }
              }
          }
          if(reinitiatePricingloanApps!=null && reinitiatePricingloanApps.size()>0){
              List<Loan_Application_Approval__c> loanApprovals = [SELECT Id, Loan_Application__c FROM Loan_Application_Approval__c WHERE Loan_Application__c IN :reinitiatePricingloanApps.keySet() AND Approval_Type__c=:GlobalConstants.APPROVAL_TYPE_PRICING AND Approval_Status__c=:GlobalConstants.APPROVAL_STATUS_PENDING AND Archived__c=false];
            List<Loan_Application_Approval__c> nonPendingloanApprovals = [SELECT Id, Loan_Application__c, Approver__c, Type__c, Approver_Level__c, Approval_Type__c FROM Loan_Application_Approval__c WHERE Loan_Application__c IN :clonePricingForSendBackloanApps.keySet() AND Approval_Type__c=:GlobalConstants.APPROVAL_TYPE_PRICING AND Approval_Status__c!=:GlobalConstants.APPROVAL_STATUS_PENDING AND Archived__c=false WITH SECURITY_ENFORCED];

              for(Loan_Application_Approval__c approval: loanApprovals){
                  reinitiatePricingloanApps.get(approval.Loan_Application__c).add(approval);
              }
            List<Loan_Application_Approval__c> approvalsToArchive = new List<Loan_Application_Approval__c>();
            List<Loan_Application_Approval__c> approvalsToClone = new List<Loan_Application_Approval__c>();
            List<Loan_Application_Approval__c> approvalsToRework = new List<Loan_Application_Approval__c>();

            for(Loan_Application_Approval__c approval: nonPendingloanApprovals){
                clonePricingForSendBackloanApps.get(approval.Loan_Application__c).add(approval);
                Loan_Application_Approval__c app1 = new Loan_Application_Approval__c(Archived__c=true, Id=approval.Id);
                approvalsToArchive.add(approval);
                Loan_Application_Approval__c app2 = approval;
                app2.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
                // app2.Is_Rework__c = true; // 18th Jan - Commenting as this updates Rework flag on loan application which cause Credit approvals to skip
                approvalsToClone.add(app2);
            }
            
              for(Id loanAppId: reinitiatePricingloanApps.keySet()){
                  if(reinitiatePricingloanApps.get(loanAppId).size()==0 && (!clonePricingForSendBackloanApps.containsKey(loanAppId) || clonePricingForSendBackloanApps.get(loanAppId).size()==0)){
                      Pricing_Approval_Event__e pricingEvent = new Pricing_Approval_Event__e();
                      pricingEvent.sObjectId__c = loanAppId;
                      eventsToPublish.add(pricingEvent);
                  }
              }
          approvalsToRework.addAll(approvalsToArchive);
            approvalsToRework.addAll(approvalsToClone.deepClone( false, false, false ));
            if(!approvalsToArchive.isEmpty()){
                Approval.unlock(new List<Id>((new map<Id, Loan_Application_Approval__c>(approvalsToArchive)).keySet()));
          }
            if(!approvalsToRework.isEmpty()){
                if(Schema.sObjectType.Loan_Application_Approval__c.isCreateable() && Schema.sObjectType.Loan_Application_Approval__c.isUpdateable()){
                    upsert approvalsToRework;
                }
                
            }
            

        }

          if(eventsToPublish!=null && eventsToPublish.size()>0){
              List<Database.SaveResult> results = EventBus.publish(eventsToPublish);
          }
          
              //isFirstPass=true;
          //}
          
      }
  
      public static void handleStageChangeIfNoPricingDeviationRaised(Map<Id, sObject> updatedApplications,Map<Id, sObject> oldApplications){
  
          system.debug('inside handleStageChangeIfNoPricingDeviationRaised');
          Map<Id, Loan_Application__c> loanApplications = (Map<Id, Loan_Application__c>) updatedApplications;
          Map<Id, Loan_Application__c> oldLoanApplications = (Map<Id, Loan_Application__c>) oldApplications;
          Id fourWheelerRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId();
          Id twoWheelerRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId();
          for(Loan_Application__c loan: loanApplications.values()){
            if(loan.Stage__c==GlobalConstants.STAGE_PRICING && oldLoanApplications.get(loan.Id).Stage__c!=GlobalConstants.STAGE_PRICING){
                loan.Is_Charge_Changed__c=false;
            }//is charge changed was not getting reset due to which case was moving to pricing from psd - Neha
              if(loan.RecordTypeId == fourWheelerRecordTypeId){
                  // SFAU-5722 - Add Pre Approved Flag
                  if(loan.Bre_Decision__c == GlobalConstants.BRE_DECISION_NSTP || loan.Pre_Approved_Flag__c){
                      if(loan.No_Pricing_Deviation__c==true && oldLoanApplications.get(loan.Id).Stage__c!=GlobalConstants.STAGE_PRICING && loan.Stage__c==GlobalConstants.STAGE_PRICING){
                          loan.Stage__c=GlobalConstants.STAGE_PSD;
                      }else if(loan.No_Pricing_Deviation__c==true && oldLoanApplications.get(loan.Id).No_Pricing_Deviation__c==false && loan.Stage__c==GlobalConstants.STAGE_PRICING){
                        loan.Stage__c=GlobalConstants.STAGE_PSD;
                      }
                  }
                  // SFAU-5722 - Add Pre Approved Flag
                  if(loan.Bre_Decision__c == GlobalConstants.BRE_DECISION_STP || loan.Pre_Approved_Flag__c){
                      if(loan.No_Pricing_Deviation__c==true && oldLoanApplications.get(loan.Id).No_Pricing_Deviation__c==false && loan.Stage__c==GlobalConstants.STAGE_PRICING){
                          loan.Stage__c=GlobalConstants.STAGE_PSD;
                      }
                  }
                  
              }else if(loan.RecordTypeId == twoWheelerRecordTypeId){
                  // SFAU-5722 - Add Pre Approved Flag
                  if(loan.Bre_Decision__c == GlobalConstants.BRE_DECISION_NSTP || loan.Pre_Approved_Flag__c){
                      if(loan.No_Pricing_Deviation__c==true && oldLoanApplications.get(loan.Id).Stage__c!=GlobalConstants.STAGE_PRICING && loan.Stage__c==GlobalConstants.STAGE_PRICING){
                          loan.Stage__c=GlobalConstants.STAGE_DDE;
                      }else if(loan.No_Pricing_Deviation__c==true && oldLoanApplications.get(loan.Id).No_Pricing_Deviation__c==false && loan.Stage__c==GlobalConstants.STAGE_PRICING){
                        loan.Stage__c=GlobalConstants.STAGE_DDE;
                      }
                  }
                  // SFAU-5722 - Add Pre Approved Flag
                  if(loan.Bre_Decision__c == GlobalConstants.BRE_DECISION_STP || loan.Pre_Approved_Flag__c){
                      if(loan.No_Pricing_Deviation__c==true && oldLoanApplications.get(loan.Id).No_Pricing_Deviation__c==false && loan.Stage__c==GlobalConstants.STAGE_PRICING){
                          loan.Stage__c=GlobalConstants.STAGE_DDE;
                      }
                  }
                }else{
                    if(loan.Bre_Decision__c == GlobalConstants.BRE_DECISION_NSTP){
                        if(loan.No_Pricing_Deviation__c==true && oldLoanApplications.get(loan.Id).Stage__c!=GlobalConstants.STAGE_PRICING && loan.Stage__c==GlobalConstants.STAGE_PRICING){
                            loan.Stage__c=GlobalConstants.STAGE_PSD;
                        }else if(loan.No_Pricing_Deviation__c==true && oldLoanApplications.get(loan.Id).No_Pricing_Deviation__c==false && loan.Stage__c==GlobalConstants.STAGE_PRICING){
                            loan.Stage__c=GlobalConstants.STAGE_PSD;
                        }
                    }
                    if(loan.Bre_Decision__c == GlobalConstants.BRE_DECISION_STP){
                        if(loan.No_Pricing_Deviation__c==true && oldLoanApplications.get(loan.Id).No_Pricing_Deviation__c==false && loan.Stage__c==GlobalConstants.STAGE_PRICING){
                            loan.Stage__c=GlobalConstants.STAGE_PSD;
                        }
                    }
                }//else part - R2-1693,1691
          }
      }
  
      public static void handlePricingApprovalPlatformEvent(Map<Id, Pricing_Approval_Event__e> eventsMap){
  
          system.debug('inside handlePricingApprovalPlatformEvent');
          Set<Id> loanApps = new Set<Id>(); 
          for(Pricing_Approval_Event__e pricingEvent: eventsMap.values()){
              loanApps.add(pricingEvent.sObjectId__c);
          }
          /*handle single record as approvals were getting assigned to incorrect authority
          if(eventsMap!=null && eventsMap.values()!=null && eventsMap.values().size()>0){
              loanApps.add(eventsMap.values()[0].sObjectId__c);
          }*/
          LosPricingApproval.callLoanApplicationAssignmentHelperMethod(loanApps);
      }
  }