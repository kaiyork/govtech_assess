import requests
## will fail cause url provided is not valid , below code assumes its valid
url = 'https://FDQN/vend_ip'
try:
    response = requests.get(url)
    data = response.json()
    ip_address = data['ip_address']
    subnet_size = data['subnet_size']
    print(f"Retrieved IP address: {ip_address}, Subnet size: {subnet_size}")
## Exception handling , we will put the provided values here
except requests.exceptions.RequestException as e:
    print("Error occurred while retrieving data from the API:", e)
