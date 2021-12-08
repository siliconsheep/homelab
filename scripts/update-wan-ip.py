#!/usr/bin/env python
# EdgeOS only supports Python 2 out-of-the box

import os
import requests
import sys

NAMECOM_API_HOST = "https://api.name.com/v4"

def get_public_ip():
    return requests.get("https://api.ipify.org/?format=json").json()['ip']

def main():
    try:
        namecom_user = os.environ["NAMECOM_USER"]
        namecom_pwd = os.environ["NAMECOM_PWD"]
        namecom_domain = os.environ["NAMECOM_DOMAIN"]
        namecom_record_id = os.environ["NAMECOM_RECORD_ID"]
    except KeyError as ke:
        print "Error - missing required environment variable " + str(ke)
        sys.exit(1)

    url = "{0}/domains/{1}/records/{2}".format(NAMECOM_API_HOST, namecom_domain, namecom_record_id)
    
    registered_ip = requests.get(url, auth=(namecom_user, namecom_pwd)).json()["answer"]
    current_ip = get_public_ip()

    if registered_ip != current_ip:
        print "Current IP ({0}) differs from registered IP ({1}), updating it...".format(current_ip, registered_ip)

        # '{"host":"www","type":"A","answer":"10.0.0.1","ttl":300}'
        body = {
            "host": "home",
            "type": "A",
            "answer": current_ip,
            "ttl": 300
        }
        r = requests.put(url, auth=(namecom_user, namecom_pwd), json=body)
        r.raise_for_status()
        print "Registered IP updated to {0}".format(r.json()["answer"])
    else:
        print "Current IP ({0}) is still the same, skipping update".format(current_ip)
    

if __name__ == "__main__":
    main()
