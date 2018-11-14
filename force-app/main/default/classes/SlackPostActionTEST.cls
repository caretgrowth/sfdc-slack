@IsTest
public with sharing class SlackPostActionTEST {
    
    public static SlackPostAction.SlackPostRequest messageRequest;
    public static SlackPostAction.SlackPostRequest attachmentRequest;

    private static void generateData() {
        Slack_Webhook__c wh = new Slack_Webhook__c();
        wh.Name = 'Test Webhook Name';
        wh.Enabled__c = true;
        wh.URL__c = 'https://hooks.slack.com/services/F08B45ZLF/AZ0PQU4MJ/WuKxVfy3xsD9U67TiQZO8oM5';
        insert wh;

        messageRequest = new SlackPostAction.SlackPostRequest();
        messageRequest.text = 'Test Message Text';
        messageRequest.webhookName = wh.Name;

        SlackPostAction.SlackPostRequest attachmentReq = new SlackPostAction.SlackPostRequest('Test Attachment Text', wh.Name);
        attachmentReq.fallback = 'Test Fallback';
        attachmentReq.color = '#36a64f';
        attachmentReq.pretext = 'Test Pretext';
        attachmentReq.author_name = 'Test Author';
        attachmentReq.author_link = 'https://test.authorlink.com';
        attachmentReq.author_icon = 'https://test.authorlink.com/icon.jpg';
        attachmentReq.title = 'Test Title';
        attachmentReq.title_link = 'https://test.titlelink.com';
        attachmentReq.webhookName = 'Test Webhook Name';
        attachmentReq.image_url = 'https://test.imageurl.com';
        attachmentReq.thumb_url = 'https://test.thumburl.com';
        attachmentReq.footer = 'Test Footer';
        attachmentReq.footer_icon = 'https://test.footericon.com';
        attachmentReq.ts = 123456789;
        attachmentReq.field1 = '{"title": "TEST FIELD 1","value": "Something Here1\\nSomething Else1","short": false}';
        attachmentReq.field3 = '{"title": "TEST FIELD 3","value": "Something Here3\\nSomething Else3","short": false}';
        attachmentReq.post = SlackPostAction.buildPost(attachmentReq);
        attachmentRequest = attachmentReq;
    }

    @IsTest
    static void runTests() {
        generateData();
        testBody();
        testPost();
    }

    static void testBody() {
        system.assertEquals('{"text":"Test Message Text"}',SlackPostAction.buildJsonBody(messageRequest));
        String attachmentBodyExpected = '{"attachments": [{"ts":123456789,"title_link":"https://test.titlelink.com",'
            + '"title":"Test Title","thumb_url":"https://test.thumburl.com","text":"Test Attachment Text","pretext":"Test Pretext",'
            + '"image_url":"https://test.imageurl.com","footer_icon":"https://test.footericon.com","footer":"Test Footer",'
            + '"fields":[{"value":"Something Here1\\nSomething Else1","title":"TEST FIELD 1","short":false},'
            + '{"value":"Something Here3\\nSomething Else3","title":"TEST FIELD 3","short":false}],"fallback":"Test Fallback",'
            + '"color":"#36a64f","author_name":"Test Author","author_link":"https://test.authorlink.com","author_icon":"https://test.authorlink.com/icon.jpg"}]}';
        system.assertEquals(attachmentBodyExpected,SlackPostAction.buildJsonBody(attachmentRequest));
    }

    static void testPost(){
        test.startTest();
            SlackPostAction.sendSlackPost(messageRequest);
            SlackPostAction.sendSlackPost(attachmentRequest);
        test.stopTest();
    }
}