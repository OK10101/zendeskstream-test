# Zendesk Stream

This is a small Ruby on Rails 7 application that works with the Zendesk and Google Sheet APIs. It goes through tickets in Zendesk and writes them in a new row of a predifined Google spreadsheet. Ruby version is 3.1.2

## Configuration

### Zendesk

The credentials need to be added to the file `config/zendesk/credentials.json`. There is an example file in the same directory, which shows how it needs to look like:

```
{
  "url": "***",
  "username": "***",
  "token": "***"
}
```

### Google sheets

The credentials need to be added to the file `config/spreadsheet/service_account_credentials.json`. There is an example file in the same directory, which shows how it needs to look like:

```
{
  "type": "****",
  "project_id": "***",
  "private_key_id": "***",
  "private_key": "-----BEGIN PRIVATE KEY-----****-----END PRIVATE KEY-----\n",
  "client_email": "example@example.gserviceaccount.com",
  "client_id": "****",
  "auth_uri": "****",
  "token_uri": "****",
  "auth_provider_x509_cert_url": "****",
  "client_x509_cert_url": "****"
}
```

The spreadsheet needs to be shared with the `client_email` in order for the API to work.

### Environment variables

We need to set `SHEET_ID` environemnt variable. That is the sheet on which we are writing the tickets. For development purposes, a `.env` file can be created in the root, where we set the variable thanks to the `dotenv-rails` gem. In production it is set in the `~/.bashrc` file. Consider adding the Zendesk and Google sheet credentials inside environemnt variables in the future.


## Deployments and SSH

The code for the app lives in an EC2 instance. To SSH into it execute the following command:

`ssh -i ~/.ssh/my-pem-file.pem deployment@3.93.152.241`

Notice the `deployment` user.

The code is located under `/apps/zendeskstream` and in order to get the latest changes just pull them: `cd apps/zendeskstream && git pull origin main`

Running the server is done through: `RAILS_ENV=production bin/rails s -b 0.0.0.0 -d`. Notice the `-d` which stands for detached. To stop the server from running: `lsof -i :3000` and kill the process.

Accessing the console: `RAILS_ENV=production bin/rails c`

## Cron Jobs

On the EC2 instance a cron job is setup that runs the rake task for streaming tickets every 15 minutes. You can check it out by running `crontab -l`. Changing the crontab can be done with the command `crontab -e`. The log of the cron job is logged under `log/cron_log.log`

## Internal Ticket model

In order to check which tickets have been imported and which not, we can check out the `Ticket` model. Go to the console and run `Ticket.all`. Due to having just one model we are running an sqlite database. Consider changing it to something else in the future, with changes in computing and storage demand.