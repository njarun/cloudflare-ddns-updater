[![N|Solid](https://cdn4.iconfinder.com/data/icons/filetype-pack-for-the-minimalist/100/SH-Bash_Shell_Script-file-program-128.png)](https://nodesource.com/products/nsolid)

# Cloudflare DDNS Updater
****
This script is used to update Dynamic DNS (DDNS) service based on Cloudflare!
Update your dynamic IP address to your cloudflare Domain DNS entry. This is a bash script and you may run it with a cronjob.

## Important:
****
Generate Auth token from the cloudflare admin settings
- Open My Profile -> API Tokens -> Create Token
- Use 'Edit zone DNS' or custom template
- Permission zone/DNS/Edit, fill as per your requirement
- Make sure you include all required zones in the token

## Installation:
****
 **Download the ip_updater.sh file to your server/system**
```sh
git clone https://github.com/njarun/cloudflare-ddns-updater.git
or
wget "https://raw.githubusercontent.com/njarun/cloudflare-ddns-updater/main/ip_updater.sh"
``` 
 **Edit the ip_updater.sh file and fill in your zone/domain details**
```sh
nano ip_updater.sh
```
 **Make it executable**
```sh
chmod +x ip_updater.sh
```
 **Execute it or run as cronjob**
```sh
./ip_updater.sh
```
 **Or create an entry in the www-data contab**
```sh
## I Added it in the www-data user and adjusted the file permissions accordingly :D
sudo -u www-data crontab -e
## Add the cron job
*/5 * * * * /path/to/ip_updater.sh
```

## What it does
****
The script pulls the current public IP of the machine using the AWS API `https://checkip.amazonaws.com`
Enter your zone/domains add them to the associated array `zoneMap`. You can have multiple zones and domains, thats why we use the associated array.
The script iterates through the zone and finds the zone id 
Then it loops throght the domain names and fetches the current Ip
If the dns IP and public IP are different, then it updates the DNS IP address in the cloudflare.

## Note:
**If your A record is not cloudflare proxied, change proxied: false in the IP update API**

