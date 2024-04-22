import os 
import requests 
from pydo import Client



client = Client(token=os.environ.get("DIGITALOCEAN_TOKEN"))

droplets = client.droplets.list()['droplets']

# gather droplets info
droplets_info = {
    droplet['name']: {
        'ip': droplet['networks']['v4'][1]['ip_address'],
        'id': droplet['id']
    } for droplet in droplets
}

failure_counter_path = "./droplets_status.txt"


def read_failure_counts():
    try:
        with open(failure_counter_path, "r") as file:
            return {line.split(":")[0].strip(): int(line.split(":")[1].strip()) for line in file.readlines()}
    except FileNotFoundError:
        return {name: 0 for name in droplets_info}

def write_failure_counts(counts):
    with open(failure_counter_path, "w") as file:
        for droplet_name, count in counts.items():
            file.write(f"{droplet_name}: {count}\n")

def increment_failure_count(droplet_name):
    counts = read_failure_counts()
    counts[droplet_name] = counts.get(droplet_name, 0) + 1
    write_failure_counts(counts)
    return counts[droplet_name]

def reset_failure_count(droplet_name):
    counts = read_failure_counts()
    counts[droplet_name] = 0
    write_failure_counts(counts)

def reboot_droplet(droplet_name):
    droplet_id = droplets_info[droplet_name]['id']
    req = {"type": "reboot"}
    client.droplet_actions.post(droplet_id=droplet_id, body=req)
    print(f"Droplet {droplet_name} rebooted.")


def health_check(droplet_name, timeout=10):
    try:
        ip_host = 'http://' + droplets_info[droplet_name]['ip']
        response = requests.get(ip_host, timeout=timeout)
        if 200 <= response.status_code < 300:
            reset_failure_count(droplet_name)
            return "Success"
        else:
            raise Exception(f"Received status code {response.status_code}")
    except (requests.exceptions.Timeout, Exception) as e:
        count = increment_failure_count(droplet_name)
        print(f"Failure {count} for {droplet_name}: {str(e)}")
        if count >= 3:
            reboot_droplet(droplet_name)
            reset_failure_count(droplet_name)
        return "Unsuccessful"

if __name__ == "__main__":
    for droplet_name in droplets_info:
        result = health_check(droplet_name)
        print(f"Health check for {droplet_name}: {result}")




