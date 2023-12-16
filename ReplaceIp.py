import re

def replace_ip_in_file(filename, ip_filename):
    # Read the IP address
    with open(ip_filename, 'r') as f:
        raw_ip = f.read().strip()

    # Use regex to extract the IP address
    ip_match = re.search(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', raw_ip)
    if ip_match:
        ip = ip_match.group(1)
    else:
        raise ValueError("IP address not found in the given file.")

    # Read the original file content
    with open(filename, 'r') as f:
        content = f.read()

    # Replace the placeholder with the IP address
    content = content.replace("REPLACE_IP", ip)

    # Write the updated content back to the file
    with open(filename, 'w') as f:
        f.write(content)

# Call the function to replace IP
replace_ip_in_file('inventory/inventory.yml', 'ec2_ip.txt')
