@IsTest
public with sharing class SlackPostActionTEST {

    @IsTest
    static void testPost(){

        Slack_Webhook__c wh = new Slack_Webhook__c();
        wh.Name = 'Test Webhook Name';
        wh.Enabled__c = true;
        wh.URL__c = 'https://hooks.slack.com/services/F08B45ZLF/AZ0PQU4MJ/WuKxVfy3xsD9U67TiQZO8oM5';
        insert wh;

        SlackPostAction.SlackPostRequest spr = new SlackPostAction.SlackPostRequest('Test Text', wh.Name);
        spr.fallback = 'Test Fallback';
        spr.color = '#36a64f';
        spr.pretext = 'Test Pretext';
        spr.author_name = 'Test Author';
        spr.author_link = 'https://test.authorlink.com';
        spr.author_icon = 'https://test.authorlink.com/icon.jpg';
        spr.title = 'Test Title';
        spr.title_link = 'https://test.titlelink.com';
        spr.webhookName = 'Test Webhook Name';
        spr.field1 = '{"title": "TEST FIELD 1","value": "Something Here1\\nSomething Else1","short": false}';
        spr.field3 = '{"title": "TEST FIELD 3","value": "Something Here3\\nSomething Else3","short": false}';

        test.startTest();
            SlackPostAction.sendSlackPost(spr);
        test.stopTest();
    }
}