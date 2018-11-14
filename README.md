# sfdc-slack

This package is intended to give Admins the capability to send highly customized slack messages via process builder or visual flows.

## Trying Out in SFDX scratch org

[![Deploy](https://deploy-to-sfdx.com/dist/assets/images/DeployToSFDX.svg)](https://deploy-to-sfdx.com/)

## Deployment

Test in sandbox first! You will first need to authorize your org(s). Checkout [Trailhead](https://trailhead.salesforce.com/en/content/learn/modules/sfdx_app_dev/sfdx_app_dev_setup_dx) to get started with SFDX.

```shell
git clone git@github.com:mikesimps/sfdc-slack.git

cd sfdc-slack

sfdx force:source:convert -d deploy -r force-app

sfdx force:mdapi:deploy -d deploy -u YOUR_ORG  -l RunSpecifiedTests -r SlackPostActionTEST
```

Be sure to also grant users to the `Slack Admin` permission set that will be able to manage the webhook entries.

## Adding Webhooks to Slack Workspace

You will need to create your own App in your Slack workspace as an admin or have your admin create the app and add you as a collaborator. Documentation for this setup is pretty straight forward.

https://api.slack.com/slack-apps

Ultimately, you need an incoming webhook URL that is unique for your workspace and channel. The screen will look similar to the image below. That URL will be required when adding webhook records to the custom object. These urls do not require authentication so be careful with who you expose these to.

![image](https://user-images.githubusercontent.com/3085186/48458237-72617b00-e793-11e8-8d3d-3347c0ec92fb.png)

Once you have the URLs you will need to add them to the custom object. Be sure to note the Name you use as it will be required when building the process builder.

![image](https://user-images.githubusercontent.com/3085186/48460007-b0ae6880-e79a-11e8-8aa6-b883b2b6c95a.png)

## Creating Posts Via Process Builder

Most of the fields are straightforward text values and will match exactly with the [slack message api specification](https://api.slack.com/docs/messages). The only required values for you to specify are the Webhook Name from the record you created and the text you want to send.

![image](https://user-images.githubusercontent.com/3085186/48458479-82c62580-e794-11e8-8465-b031a1676122.png)

If you decide to do a more complex attachment message, for each of your fields will need to be text values that presented as a JSON object.

```JSON
{
    "title": "TEST FIELD 1",
    "value": "Something Here1\nSomething Else1",
    "short": false
}
```

Flattened it looks like this:
```JSON
{ "title": "TEST FIELD 1","value": "Something Here1\nSomething Else1","short": false}
```

Notice the `\n` in the value text. This is how you get the text to display on separate lines. It is recommended that you create a formula to build this text. For example:

```Java
'{"title": "TEST FIELD1","value":"' + Custom_Value_Field__c + ',"short":false"}'
```

Where Custom_Value_Field__c is a formula on the object you want to display with the value of `Some_Field__c + '\n' + Some_Other_Field__c`. If you are doing an extensive message (like notification of an Opportunity Closing, this could get quite lengthy and is a good idea to have it as a dynamic formula rather than hardcoded in the process).

## Attachment Post Example

![image](https://user-images.githubusercontent.com/3085186/48457899-3b3e9a00-e792-11e8-959e-9cad41a34ffa.png)

## Message Post Example

![image](https://user-images.githubusercontent.com/3085186/48458041-ae481080-e792-11e8-86c9-c2b65aaa0072.png)

## Issues and Contributions

If you have questions that are not clarified by the documentation, please feel free to submit an issue for clarification. Additional contributions are always welcomed!
