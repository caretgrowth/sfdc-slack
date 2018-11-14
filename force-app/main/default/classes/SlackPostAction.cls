public class SlackPostAction {
    
    public class SlackPost {

        public String fallback;
        public String color;
        public String pretext;
        public String author_name;
        public String author_link;
        public String author_icon;
        public String title;
        public String title_link;
        public String image_url;
        public String thumb_url;
        public String footer;
        public String footer_icon;
        public Integer ts;
        public String text;
        public List<SlackField> fields = new List<SlackField>();

        public SlackPost(String text) {
            this.text = text;
        }

        public Boolean isAttachment() {
            return this.fallback != null || this.color != null || this.pretext != null 
                || this.author_name != null || this.author_link != null || this.author_icon != null 
                || this.title != null || this.title_link != null || this.fields != null 
                || this.image_url != null || this.thumb_url != null || this.footer != null
                || this.footer_icon != null || this.ts != null;
        }

        public void addFields(String field1, String field2, String field3, String field4, String field5) {
            List<String> inputFields = new List<String>{field1, field2, field3, field4, field5};
            Integer fieldCount = 0;

            for(String f: inputFields) {
                if(f != null) {
                    this.fields.add((SlackField)JSON.deserialize(f.replace('"short":', '"shortB":'), SlackField.class));
                    fieldCount++;
                }
            }
            if(fieldCount == 0) { this.fields = null; }
        }
    }

    private class SlackField {
        public String title;
        public String value;
        public Boolean shortB;
    }

    public class SlackPostRequest {
        public SlackPost post;
        public String body;

        // SlackPost Variables
        @InvocableVariable(label='Text' required=true)
        public String text;
        @InvocableVariable(label='Fallback Text' required=false)
        public String fallback;
        @InvocableVariable(label='Color hex value' required=false)
        public String color;
        @InvocableVariable(label='Pretext' required=false)
        public String pretext;
        @InvocableVariable(label='Author Name' required=false)
        public String author_name;
        @InvocableVariable(label='Author Link' required=false)
        public String author_link;
        @InvocableVariable(label='Author Icon' required=false)
        public String author_icon;
        @InvocableVariable(label='Title' required=false)
        public String title;
        @InvocableVariable(label='Title Link' required=false)
        public String title_link;
        @InvocableVariable(label='Image URL' required=false)
        public String image_url;
        @InvocableVariable(label='Thumb URL' required=false)
        public String thumb_url;
        @InvocableVariable(label='Footer Text' required=false)
        public String footer;
        @InvocableVariable(label='Footer Icon' required=false)
        public String footer_icon;
        @InvocableVariable(label='Timestamp' required=false)
        public Integer ts;

        // Specific to the SlackPostRequest
        @InvocableVariable(label='Webhook Name' required=true)
        public String webhookName;
        @InvocableVariable(label='Field 1' required=false)
        public String field1;
        @InvocableVariable(label='Field 2' required=false)    
        public String field2;
        @InvocableVariable(label='Field 3' required=false)
        public String field3;
        @InvocableVariable(label='Field 4' required=false)
        public String field4;
        @InvocableVariable(label='Field 5' required=false)
        public String field5;

        public SlackPostRequest(){}

        public SlackPostRequest(String text, String webhookName) {
            this.text = text;
            this.post = new SlackPost(text);
            this.webhookName = webhookName;
        }
    }

    public static void sendSlackPost(SlackPostRequest request) {
        sendSlackPosts(new List<SlackPostRequest>{request});
    }

    @InvocableMethod(label='Post To Slack' description='Post Message To Slack Channel')
    public static void sendSlackPosts(List<SlackPostRequest> requests) {
        Set<String> webhookNames =  new Set<String>();
        for(SlackPostRequest spr: requests) {
            webhookNames.add(spr.webhookName);
        }
        Map<String, String> webhooks = new Map<String, String>();
        for(Slack_Webhook__c w: [SELECT Name, URL__c FROM Slack_Webhook__c WHERE Name = :webhookNames AND Enabled__c = true LIMIT 1]) {
            webhooks.put(w.name, w.URL__c);
        }

        for(SlackPostRequest r: requests) {
            String url = webhooks.get(r.webhookName);

            if(url != null) {
                r.body = buildJsonBody(r);
                postToSlack(r.body, url);
            }
        }
    }

    public static SlackPost buildPost(SlackPostRequest r) {
        r.post = new SlackPost(r.text);
        r.post.addFields(r.field1, r.field2, r.field3, r.field4, r.field5);
        r.post.fallback = r.fallback != null ? r.fallback : null;
        r.post.color = r.color != null ? r.color : null;
        r.post.pretext = r.pretext != null ? r.pretext : null;
        r.post.author_name = r.author_name != null ? r.author_name : null;
        r.post.author_link = r.author_link != null ? r.author_link : null;
        r.post.author_icon = r.author_icon != null ? r.author_icon : null;
        r.post.title = r.title != null ? r.title : null;
        r.post.title_link = r.title_link != null ? r.title_link : null;
        r.post.image_url = r.image_url != null ? r.image_url : null;
        r.post.thumb_url = r.thumb_url != null ? r.thumb_url : null;
        r.post.footer = r.footer != null ? r.footer : null;
        r.post.footer_icon = r.footer_icon != null ? r.footer_icon : null;
        r.post.ts = r.ts != null ? r.ts : null;

        return r.post;
    }

    public static String buildJsonBody(SlackPostRequest postReq) {
        SlackPost post = buildPost(postReq);
        String body = JSON.serialize(post, true).replace('"shortB":', '"short":');
        if(post.isAttachment()) {
            body = '{"attachments": [' + body + ']}';
        }
        return body;
    }

    public static void postToSlack(String body, String url) {
        System.enqueueJob(new qCallOut(url, 'POST', body));
    }

    public class qCallOut implements System.Queueable, Database.AllowsCallouts {
         
        private final String url;
        private final String method;
        private final String body;
         
        public qCallOut(String url, String method, String body) {
            this.url = url;
            this.method = method;
            this.body = body;
        }
         
        public void execute(System.QueueableContext ctx) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(method);
            req.setBody(body);
            Http http = new Http();
            if(!Test.isRunningTest()) {
                HttpResponse res = http.send(req);
            }
        }
    }
}
