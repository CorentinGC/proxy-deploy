import os
import sys
import yaml
import re
from copy import deepcopy

params = sys.argv
project_name = params[1]

if(len(params) > 2):
    quantity =  int(params[2])

print(params)
REGION = os.getenv('AWS_REGION', "us-east-1")
INPUT_FILE = "./docker-compose.yml"
OUTPUT_FILE = f"./clusters/docker-compose.{project_name}.yml"

stack = yaml.safe_load(open(INPUT_FILE))
services = stack["services"]

# def update_services():
#     global services

#     base_port = int(services["proxy"]["ports"][0].split(":")[0])

#     for i in range(quantity):
#         new_port = base_port+i
#         services[f"{project_name}-{i}"] = deepcopy(services["proxy"])
#         services[f"{project_name}-{i}"]["ports"] = [f"{new_port}:{new_port}"]
#         services[f"{project_name}-{i}"]["environment"] = {"PROXY_PORT": new_port}
#     del services["proxy"]

#     # for service_name, service in services.items():
#     #     if service_name == "proxy":
#     #         service["logging"] = {
#     #             'driver': 'awslogs',
#     #             'options': {
#     #                 'awslogs-group': f"{project_name}",
#     #                 'awslogs-region': f"{REGION}",
#     #                 'awslogs-stream-prefix': f'{project_name}'
#     #                 }
#     #             }

# Write the new docker-compose.yml file.
def create_deploy_docker_compose_file():
    with open(OUTPUT_FILE, "w") as out_file:
        yaml.safe_dump(stack, out_file, default_flow_style=False)

    # yaml that is produced is a bit buggy.
    fh = open(OUTPUT_FILE, "r+")
    lines = map(lambda a: re.sub(r"^\s{4}-", "      -", a), fh.readlines())
    fh.close()
    with open(OUTPUT_FILE, "w") as f:
        f.writelines(lines)

    print("Wrote new compose file.")
    print(f"COMPOSE_FILE={OUTPUT_FILE}")

# if(len(params) > 2):
#     update_services()

create_deploy_docker_compose_file()