import os
import subprocess
import sys
import time
import yaml
import re
from copy import deepcopy

params = sys.argv

vpc_id = params[1]
security_group = params[2]
subnet_a = params[3]
subnet_b = params[4]
project_name = params[5]
# quantity = int(params[6])

INPUT_FILE = "./ecs-params.yml"
OUTPUT_FILE = f"./clusters/ecs-params.{project_name}.yml"

stack = yaml.safe_load(open(INPUT_FILE))
services = stack["run_params"]["network_configuration"]

services["awsvpc_configuration"]["subnets"] = [subnet_a, subnet_b]
services["awsvpc_configuration"]["security_groups"] = [security_group]

# for i in range(quantity):
#     stack["task_definition"]["services"][f"{project_name}-{i}"] = deepcopy(stack["task_definition"]["services"]["proxy"])
# del stack["task_definition"]["services"]["proxy"]

with open(OUTPUT_FILE, "w") as out_file:
    yaml.dump(stack, out_file, default_flow_style=False)

# yaml that is produced is a bit buggy.
fh = open(OUTPUT_FILE, "r+")
lines = map(lambda a: re.sub(r"^\s{4}-", "      -", a), fh.readlines())
fh.close()
with open(OUTPUT_FILE, "w") as f:
    f.writelines(lines)

print("Wrote new ecs params file.")
print(f"ECS_PARAMS_FILE={OUTPUT_FILE}")