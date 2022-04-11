import os
import sys
import yaml
import re

params = sys.argv
project_name = params[1]

REGION = os.getenv('AWS_REGION', "us-east-1")
INPUT_FILE = "./docker-compose.yml"
OUTPUT_FILE = f"./clusters/docker-compose.{project_name}.yml"

stack = yaml.safe_load(open(INPUT_FILE))
services = stack["services"]

def update_services():
    global services

    # del services[project_name]
    # for service_name, service in services.items():
    #     if service_name == "proxy":
    #         service["logging"] = {
    #             'driver': 'awslogs',
    #             'options': {
    #                 'awslogs-group': f"{project_name}",
    #                 'awslogs-region': f"{REGION}",
    #                 'awslogs-stream-prefix': f'{project_name}'
    #                 }
    #             }


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

# update_services()
create_deploy_docker_compose_file()