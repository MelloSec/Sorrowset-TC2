import re

def replace_hostname_in_file(filename, dns_filename):
    # Read the DNS hostname
    with open(dns_filename, 'r') as f:
        content = f.read().strip()

    # Extract the domain
    domain_match = re.search(r'"domain"\s*=\s*"([\w\-\.]+)"', content)
    if not domain_match:
        raise ValueError("Domain not found in the given file.")
    domain = domain_match.group(1)

    # Extract the hostname
    hostname_match = re.search(r'"hostname"\s*=\s*"([\w\-]+)"', content)
    if not hostname_match:
        raise ValueError("Hostname not found in the given file.")
    hostname = hostname_match.group(1)

    # Combine the hostname and domain
    full_domain = f"{hostname}.{domain}"

    # Read the template file content
    with open(filename, 'r') as f:
        template_content = f.read()

    # Replace the placeholder in the template
    template_content = template_content.replace("{{ host_domain }}", full_domain)

    # Write the updated content back to the file
    with open(filename, 'w') as f:
        f.write(template_content)

# Call the function to replace the DNS hostname
replace_hostname_in_file('FLNC/Template/Caddyfile.j2', 'namecheap_dns.txt')
